//
//  AuthService.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 27.01.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import PromiseKit
import Firebase
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

  private let tokenKey = "token"
  private let fcmTokenKey = "fcmToken"
  
  private let avatarURLKey = "avatarURL"
  private let emailKey = "email"
  private let levelKey = "level"
  private let nameKey = "name"
  private let phoneKey = "phone"
  private let aboutKey = "about"
  private let fcmTokenDeliveredKey = "fcmTokenDelivered"

  
  func logout() -> Promise<()> {
    return Promise {  (fulfill, error) in
      try Locksmith.deleteDataForUserAccount(userAccount: "AMP")
      fulfill(())
    }
  }
  
  
  func store(userCredentials: UserCredentials) -> Promise<UserCredentials> {
    return Promise { (fulfill, error) in
      
      try Locksmith.updateData(data: [tokenKey: userCredentials.token], forUserAccount: "AMP")
      UserDefaults.standard.set(userCredentials.avaurl, forKey: avatarURLKey)
      UserDefaults.standard.set(userCredentials.email, forKey: emailKey)
      UserDefaults.standard.set(userCredentials.level, forKey: levelKey)
      UserDefaults.standard.set(userCredentials.name, forKey: nameKey)
      UserDefaults.standard.set(userCredentials.phone, forKey: phoneKey)
      UserDefaults.standard.set(userCredentials.about, forKey: aboutKey)
      UserDefaults.standard.set(userCredentials.fcmTokenDelivered, forKey: fcmTokenDeliveredKey)

      fulfill(userCredentials)
    }
  }
  
  
  func loadCredentials() -> UserCredentials? {
    guard let data = Locksmith.loadDataForUserAccount(userAccount: "AMP"), let token = data[tokenKey] as? String else { return nil }
    let fcmToken = Messaging.messaging().fcmToken
    
    return UserCredentials(phone: UserDefaults.standard.string(forKey: phoneKey),
                           name: UserDefaults.standard.string(forKey: nameKey),
                           email: UserDefaults.standard.string(forKey: emailKey),
                           level: UserDefaults.standard.object(forKey: levelKey) as? Int ?? 0,
                           avaurl: UserDefaults.standard.string(forKey: avatarURLKey),
                           about: UserDefaults.standard.string(forKey: aboutKey),
                           token: token,
                           fcmToken: fcmToken,
                           fcmTokenDelivered: UserDefaults.standard.bool(forKey: fcmTokenDeliveredKey))
  }
  
  
  let baseURL = "https://usefulness.club/amp/sitebackend/0"
  
  enum AuthError: Error {
    case cantVerifyPhone
    case phoneIncorrect
    case codeIncorrect
  }
  
  
  func getAuthCode(for phone: String) -> (Promise<String>, Cancel) {
    
    var isCanceled = false
    
    return ( Promise { (fulfill, error) in
      PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { verificationId, authError in
        guard !isCanceled else { return }
        guard authError == nil else {
          error(authError!)
          return
        }
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
        if let firError = firError {
          error(firError)
        }
        else {
          resolve(token!)
        }
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
    return
      firstly {
        firSignInAnonymously()
      }.then {
        self.getFirTokenFor(user: $0)
      }.then {
        self.ampSignIn(firToken: $0)
    }
  }
  
}
