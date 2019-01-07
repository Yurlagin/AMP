//
//  AuthSideEffects.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 27.01.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift
import Locksmith
import Firebase

enum AuthMiddleWare {}

extension AuthMiddleWare {
  
  static func requestSms(authService: AuthService) -> MiddlewareItem {
    return { (action: Action, dispatch: @escaping DispatchFunction) in
      switch action {
      case let action as RequestSmsAction:
        let (verificationIdPromise, _) = authService.getVerificationId(for: action.phone)
        verificationIdPromise
          .then { dispatch(SetLoginState(.phoneFlow(.smsRequestSuccess(verificationId: $0)))) }
          .catch { dispatch(SetLoginState(.phoneFlow(.smsRequestFail(AuthServiceError(error: $0))))) }
        
      default:
        break
      }
    }
  }
  
  static func logIn(authService: AuthService) -> MiddlewareItem {
    return { (action: Action, dispatch: @escaping DispatchFunction) in
      
      let bgQeue = DispatchQueue.global(qos: .userInitiated)
      
      switch action {
      case let action as RequestTokenAction:
        
        func loginErrorHandler(error: Error) {
          let authServiceError = AuthServiceError(error: error)
          switch authServiceError {
          case .smsSessionExpired:
            dispatch(SetLoginState(.phoneFlow(.smsRequestFail(.smsSessionExpired))))
            
          default:
            dispatch(SetLoginState(.phoneFlow(.requestTokenFail(verificationId: action.verificationId,
                                                                error: authServiceError))))
          }
        }
        
        authService.login(smsCode: action.smsCode, verificationId: action.verificationId)
          .then { dispatch(SetLoginState(.loggedIn(user: $0, logoutStatus: .none))) }
          .catch (execute: loginErrorHandler)
        
      case is RequestAnonymousToken:
        authService.signInAnonymously()
          .then { dispatch(SetLoginState(.loggedIn(user: $0, logoutStatus: .none))) }
          .catch { dispatch(SetLoginState(.anonymousFlow(.fail(AuthServiceError(error: $0))))) }
        
      case is Logout:
        authService.logout()
          .then { dispatch (SetLoginState(.none)) }
          .catch { dispatch (LogoutErrorAction($0)) }
        
      default:
        break
      }
    }
  }
  
}

