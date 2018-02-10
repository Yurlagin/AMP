//
//  AuthService.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 27.01.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import PromiseKit
import FirebaseAuth
import RealmSwift
import Locksmith


protocol AuthServiceProtocol {
  
  typealias Token = String
  
  func getAuthCode(for phone: String) -> (Promise<String>, Cancel)
  
  func login(smsCode: String, verificationId: String) -> Promise<UserCredentials>
  
  func signInAnonymously() -> Promise<UserCredentials>
  
  func store(userCredentials: UserCredentials) -> Promise<UserCredentials>
  
  func logout() -> Promise<()>
  
}

typealias Cancel = () -> ()

struct AuthService: AuthServiceProtocol {
  
  func logout() -> Promise<()> {
    return Promise {  (fulfill, error) in
      try Locksmith.deleteDataForUserAccount(userAccount: "AMP")
      let realm = try Realm()
      let settings = realm.objects(RLMSettings.self)
      try realm.write { realm.delete(settings) }
      fulfill(())
    }
  }
  
  
  func store(userCredentials: UserCredentials) -> Promise<UserCredentials> {
    return Promise { (fulfill, error) in
      
      try Locksmith.updateData(data: ["token": userCredentials.token], forUserAccount: "AMP")
      let realm = try Realm()
      let settings: RLMSettings
      if let rlmSettings = realm.objects(RLMSettings.self).first {
        settings = rlmSettings
      } else {
        settings = RLMSettings(); try realm.write { realm.add(settings) }
      }
      try realm.write {
        settings.avaurl = userCredentials.avaurl
        settings.email = userCredentials.email
        settings.level = userCredentials.level
        settings.name = userCredentials.name
        settings.phone = userCredentials.phone
      }

      fulfill(userCredentials)
      
    }
  }
  
  
  func loadCredentials() -> UserCredentials? {
    guard let data = Locksmith.loadDataForUserAccount(userAccount: "AMP"), let token = data["token"] as? String else { return nil }
    let rlmSettings = (try? Realm())?.objects(RLMSettings.self).first ?? RLMSettings()
    return UserCredentials(phone: rlmSettings.phone,
                           name: rlmSettings.name,
                           email: rlmSettings.email,
                           level: rlmSettings.level,
                           avaurl: rlmSettings.avaurl,
                           token: token)
  }
  
  
  let baseURL = "https://usefulness.club/amp/sitebackend/0"
  
  
  enum AuthError: Error {
    case cantVerifyPhone
    case phoneIncorrect
    case codeIncorrect
  }
  
  //MARK: FireBase phone auth
  
  func getAuthCode(for phone: String) -> (Promise<String>, Cancel) {
    
    var isCanceled = false
    
    return ( Promise { (fulfill, error) in
      PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { verificationId, authError in
        guard !isCanceled else { return }
        guard authError == nil else {
          error(authError!)
          return
        }
//        print ("Got verificationId: \(verificationId!)")
        fulfill(verificationId!)
      }
    }, {
      isCanceled = true
    })
    
  }
  
  
  func login(smsCode: String, verificationId: String) -> Promise<UserCredentials> {
    return firSmsCodeSignIn(smsCode: smsCode, verificationId: verificationId)
      .then { self.getFirTokenFor(user: $0) }
      .then { self.ampSignIn(firToken: $0) }
  }
  
  // MARK: FireBase anonymous auth

  private func firSmsCodeSignIn(smsCode: String, verificationId: String) -> Promise<User> {
    let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: smsCode)
    return Promise { (fulfill, error) in
      Auth.auth().signIn(with: credential) { (user, firError) in
        if let firError = firError {
          error(firError)
        } else {
          fulfill(user!)
        }
      }
    }
  }
  
  private func firSignInAnonymously() -> Promise<User> {
    return Promise(resolvers: { (resolve, error) in
      Auth.auth().signInAnonymously { (user, authError) in
        if let authError = authError { error(authError) }
        else { resolve(user!) }
      }
    })
  }
  
  private func getFirTokenFor(user: User) -> Promise<String> {
    return Promise(resolvers: { (resolve, error) in
      user.getIDToken(completion: { (token, firError) in
        if let firError = firError { error(firError) }
        else { resolve(token!) }
      })
    })
  }

  
  // MARK: AMP signIn
  
  private func ampSignIn(firToken: String) -> Promise<UserCredentials> {
    let parameters: [String: Any] = ["action": "fauth", "info": ["gtoken": firToken]]
    return Alamofire.request(baseURL, method: .post, parameters: parameters, encoding: JSONEncoding.default)
      .responseData()
      .then {
        Parser.ampUser(data: $0)
    }
  }
  
  func signInAnonymously() -> Promise<UserCredentials> {
    return firstly {
      firSignInAnonymously()
      }.then {
        self.getFirTokenFor(user: $0)
      }.then {
        self.ampSignIn(firToken: $0)
    }
  }
  
}
