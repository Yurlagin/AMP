//
//  AuthServiceProtocol.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 06/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import PromiseKit
import Firebase
import Locksmith

typealias Cancel = () -> ()
typealias Token = String

protocol AuthService {
  

  func getVerificationId(for phone: String) -> (Promise<String>, Cancel)
  
  func login(smsCode: String, verificationId: String) -> Promise<UserCredentials>
  
  func signInAnonymously() -> Promise<UserCredentials>
  
//  func store(userCredentials: UserCredentials) -> Promise<UserCredentials>
  
  func logout() -> Promise<()>
  
}
