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
  case anonimousFlow(AnonimousLoginStatus)
  case loggedIn(user: UserCredentials, logoutStatus: LogoutStatus)
  
  enum PhoneLoginStatus {
    case requestSms(phone: String)
    case smsRequestFail(Error)
    case smsRequestSuccess(verificationId: String)
    case requestToken(code: String)
    case requestTokenFail(verificationId: String, Error)
  }
  
  enum AnonimousLoginStatus {
    case request
    case failed(Error)
  }
  
  enum LogoutStatus {
    case none
    case request
    case error(Error)
  }
}


