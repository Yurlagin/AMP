//
//  AuthServiceProtocol.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 06/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import PromiseKit

typealias Cancel = () -> ()
typealias Token = String

protocol AuthService {
  func getVerificationId(for phone: String) -> (Promise<String>, Cancel)
  func login(smsCode: String, verificationId: String) -> Promise<(UserCredentials, UserInfo)>
  func signInAnonymously() -> Promise<(UserCredentials, UserInfo)>
  func logout() -> Promise<()>
}
