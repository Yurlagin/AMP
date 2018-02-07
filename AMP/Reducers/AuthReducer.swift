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
    
  case _ as ReSwiftInit:
    break
    
  case _ as RequestAnonimousToken:
    state.loginStatus = .anonimousFlow(.request)
    
  case let action as RequestSmsAction:
    state.loginStatus = .phoneFlow(.requestSms(phone: action.phone))
    
  case let action as RequestTokenAction:
    state.loginStatus = .phoneFlow(.requestToken(code: action.smsCode))
    
  case let action as SetLoginState:
    state.loginStatus = action.state
    
  case _ as Logout:
    if case .loggedIn(let user, let logoutStatus) = state.loginStatus {
      switch logoutStatus {
      case .error, .none: state.loginStatus = .loggedIn(user: user, logoutStatus: .request)
      case .request: break
      }
    }
    
  default:
    break
  }
  
  print ("§§§ auth Action: \(action)\n")
  print ("§§§ new auth state: \(state)\n")

  return state
}


