//
//  AuthReducer.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 21.01.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift

func authReducer(action: Action, state: AuthState?) -> AuthState {
  
  var state = state ?? AuthState.initFromDefaults()

  switch action {
    
  case is ReSwiftInit:
    break
    
    
  case is RequestAnonymousToken:
    state.loginStatus = .anonymousFlow(.loading)
    
    
  case let action as RequestSmsAction:
    state.loginStatus = .phoneFlow(.requestSms(phone: action.phone))
    
    
  case let action as RequestTokenAction:
    state.loginStatus = .phoneFlow(.requestToken(code: action.smsCode))
    
    
  case let action as SetLoginState:
    state.loginStatus = action.state
    
  case let action as SignedIn:
    state.loginStatus = .loggedIn(user: action.credentials, logoutStatus: .none)
    
  case is Logout:
    if case .loggedIn(let user, let logoutStatus) = state.loginStatus {
      switch logoutStatus {
      case .error, .none: state.loginStatus = .loggedIn(user: user, logoutStatus: .request)
      case .request: break
      }
    }
    
  case let action as DidRecieveFCMToken:
    if var newCredentials = state.loginStatus.userCredentials {
      newCredentials.fcmTokenDelivered = newCredentials.fcmToken == action.token
      newCredentials.fcmToken = action.token
      state.loginStatus = .loggedIn(user: newCredentials, logoutStatus: state.loginStatus.logoutStatus!)
    }
    
    
  case is FcmTokenDelivered:
    if var newCredentials = state.loginStatus.userCredentials {
      newCredentials.fcmTokenDelivered = true
      state.loginStatus = .loggedIn(user: newCredentials, logoutStatus: state.loginStatus.logoutStatus!)
    }

    
  default:
    break
  }
  
  return state
}


