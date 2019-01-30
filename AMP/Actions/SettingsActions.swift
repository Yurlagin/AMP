//
//  SettingsActions.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 13.03.2018.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift

struct SendUserInfo: Action {
  let userInfo: UserInfo
  init(_ userInfo: UserInfo) { self.userInfo = userInfo }
}

enum SendingUserInfoResult: Action {
  case success
  case error(Error)
}

struct ShownUserInfoErrorAlert: Action {}
struct LeftUserInfoScreen: Action {}

//struct
