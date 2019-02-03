//
//  File.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 03/02/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import Firebase

protocol Metrica {
  func loggedIn(loginType: LoginType, userId: Int)
  func loginFail(loginType: LoginType, reason: String)
}

enum LoginType: String {
  case mobile
  case anonymous
}


class MetricaImpl {
  static let shared = MetricaImpl()
  private init() {}
}

extension MetricaImpl: Metrica {
  func loggedIn(loginType: LoginType, userId: Int) {
    Answers.logLogin(
      withMethod: loginType.rawValue,
      success: 1,
      customAttributes: [
        "UserId": userId
      ]
    )
  }
  
  func loginFail(loginType: LoginType, reason: String) {
    Answers.logLogin(
      withMethod: loginType.rawValue,
      success: 0,
      customAttributes: ["Reason": reason]
    )
  }
}
