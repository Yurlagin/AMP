//
//  AuthSideEffects.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 27.01.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift

enum SettingsSideEffects {}

extension SettingsSideEffects {
  
  static func settingsSideEffects(settingsService: SettingsService) -> MiddlewareItem {
    return { (action: Action, dispatch: @escaping DispatchFunction) in
      switch action {
      case let action as SendUserInfo:
        settingsService.sendUserInfo(userName: action.userInfo.userName, about: action.userInfo.about)
          .then { _ -> Void in
            action.userInfo.saveToDefaults()
            dispatch(SendingUserInfoResult.success) }
          .catch { dispatch(SendingUserInfoResult.error($0)) }
      default:
        break
      }
    }
  }
  
}
