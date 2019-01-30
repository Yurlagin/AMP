//
//  AuthService.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 27.01.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import PromiseKit
import Firebase

class AuthServiceImpl {
  
  private let authStorage: AuthStorage
  
  init(authStorage: AuthStorage) {
    self.authStorage = authStorage
  }
  
  // MARK: FireBase anonymous auth
  
  private func firSmsCodeSignIn(smsCode: String, verificationId: String) -> Promise<User> {
    let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId,
                                                             verificationCode: smsCode)
    return Promise { (fulfill, error) in
      Auth.auth().signInAndRetrieveData(with: credential) { (result, firError) in
        if let firError = firError {
          error(firError)
        } else {
          fulfill(result!.user)
        }
      }
    }
  }
  
  private func firSignInAnonymously() -> Promise<User> {
    return Promise { (resolve, error) in
      Auth.auth().signInAnonymously { (result, authError) in
        if let authError = authError { error(authError) }
        else { resolve(result!.user) }
      }
    }
  }
  
  private func getFirToken(for user: User) -> Promise<String> {
    return Promise { (resolve, error) in
      user.getIDToken { (token, firError) in
        if let firError = firError {
          error(firError)
        }
        else {
          resolve(token!)
        }
      }
    }
  }
  
  // MARK: AMP signIn
  
  private func ampSignIn(firToken: String) -> Promise<(UserCredentials, UserInfo)> {
    let parameters: [String: Any] = ["action": "fauth",
                                     "info": ["gtoken": firToken]]
    guard let baseURL = Constants.baseURL else { return Promise(error: ApiError.noBaseURL) }
    return
      Alamofire.request(baseURL, method: .post, parameters: parameters, encoding: JSONEncoding.default)
        .responseData()
        .then(execute: Parser.ampUser)
  }
  
  // TODO: - Move saving activity to upper level
  private func saveInfoToStorages(info: (UserCredentials, UserInfo)) -> Promise<(UserCredentials, UserInfo)> {
    return Promise { fulfill, error in
      try authStorage.store(userCredentials: info.0)
      info.1.saveToDefaults()
      fulfill(info)
    }
  }
}



extension AuthServiceImpl: AuthService {
  func logout() -> Promise<Void> { // TODO: - add backend notification
    return Promise { (fulfill, error) in
      try authStorage.deleteCredentials()
      fulfill(())
    }
  }
  
  func getVerificationId(for phone: String) -> (Promise<String>, Cancel) {
    var isCanceled = false
    func cancel() { isCanceled = true }
    let authPromise = Promise<String>{ (fulfill, error) in
      PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { verificationId, authError in
        guard !isCanceled else { return }
        guard authError == nil else {
          error(authError!)
          return
        }
        fulfill(verificationId!)
      }
    }
    
    return (authPromise, cancel)
  }
  
  func login(smsCode: String, verificationId: String) -> Promise<(UserCredentials, UserInfo)> {
    return
      firSmsCodeSignIn(smsCode: smsCode, verificationId: verificationId)
        .then(execute: getFirToken)
        .then(execute: ampSignIn)
        .then(execute: saveInfoToStorages)
  }
  
  func signInAnonymously() -> Promise<(UserCredentials, UserInfo)> {
    return
      firstly(execute: firSignInAnonymously)
        .then(execute: getFirToken)
        .then(execute: ampSignIn)
        .then(execute: saveInfoToStorages)
  }
}
