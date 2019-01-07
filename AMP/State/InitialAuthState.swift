//
//  InitialAuthState.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 07.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//


extension AuthState {
  
  static func initFromDefaults() -> AuthState {
    if let credentials = AuthStorageImpl().loadCredentials() {
      return AuthState(loginStatus: .loggedIn(user: credentials, logoutStatus: .none))
    }
    return AuthState(loginStatus: .none)
  }
  
}

