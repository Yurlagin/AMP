//
//  File.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 03/02/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import Firebase

protocol Metrica {
  func logLogin(loginType: LoginType, userId: Int)
  func logLoginFailure(loginType: LoginType, reason: String)
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
  
  private enum UserInfoKeys {
    static let userId = "UserId"
    static let reason = "Reason"
  }
  
  private enum EventNames {
    static let didUpdateLocation = "Did Update Location"
  }
  
  func logLogin(loginType: LoginType, userId: Int) {
    Answers.logLogin(
      withMethod: loginType.rawValue,
      success: 1,
      customAttributes: [
        UserInfoKeys.userId: userId
      ]
    )
  }
  
  func logLoginFailure(loginType: LoginType, reason: String) {
    Answers.logLogin(
      withMethod: loginType.rawValue,
      success: 0,
      customAttributes: [UserInfoKeys.reason: reason]
    )
  }
  
  func logUpdateLocation(userId: Int) {
    Answers.logCustomEvent(withName: EventNames.didUpdateLocation,
                           customAttributes: [UserInfoKeys.userId: userId])
  }
}
