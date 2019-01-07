//
//  AuthState.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 20.01.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift

struct AuthState: StateType {
  var loginStatus: LoginStatus
}

enum LoginStatus {
  case none
  case phoneFlow(PhoneLoginStatus)
  case anonymousFlow(AnonymousLoginStatus)
  case loggedIn(user: UserCredentials, logoutStatus: LogoutStatus)
  
  enum PhoneLoginStatus {
    case requestSms(phone: String)
    case smsRequestFail(AuthServiceError)
    case smsRequestSuccess(verificationId: String)
    case requestToken(code: String)
    case requestTokenFail(verificationId: String, error: Error)
  }
  
  enum AnonymousLoginStatus {
    case loading
    case fail(AuthServiceError)
  }
  
  enum LogoutStatus {
    case none
    case request
    case error(Error)
  }
}


