//
//  MockAuthService.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 03.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import PromiseKit

//struct MockAuthService: AuthServiceProtocol {
//  func signInAnonymously() -> Promise<AuthServiceProtocol.Token> {
//    return Promise(value: "OkToken =]")
//  }
//  
//  
//  enum AuthError: Error {
//    case authError
//  }
//  
//  func getAuthCode(for phone: String) -> (Promise<String>, Cancel) {
//    var isCanceled = false
//    return (Promise { (fulfill, error) in
//      DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//        if !isCanceled {
//          if arc4random_uniform(2) == 0 {
//            fulfill("smsSessionId...")
//          } else {
//            error(AuthError.authError)
//          }
//        }
//      }
//      }, {
//        isCanceled = true
//        // отмена сетевого запроса или что-то такое
//    } )
//  }
//  
//  func login(with smsCode: String) -> (Promise<Token>, Cancel) {
//    var isCanceled = false
//    return (Promise { (fulfill, error) in
//      DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//        if !isCanceled {
//          if arc4random_uniform(2) == 0 {
//            fulfill("12345 =]")
//          } else {
//            error(AuthError.authError)
//          }
//        }
//      }
//      }, {
//        isCanceled = true
//    } )
//  }
  
//}

