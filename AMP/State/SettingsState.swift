//
//  SettingsState.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 26/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import Foundation

struct SettingsState: Hashable {
  var userInfo: UserInfo?
  var sendingUserInfoStatus: SendingUserInfoStatus
  var isHavingScreen: Bool
  
  enum SendingUserInfoStatus: Hashable {
    case none
    case sending(UserInfo)
    case error(description: String)
  }
}

struct UserInfo: Hashable {
  var userId: Int
  var avatarURL: String?
  var userName: String?
  var about: String?
}

extension UserInfo {
  static func loadFromDefaults() -> UserInfo? {
    let defaults = UserDefaults.standard
    guard let userId = defaults.object(forKey: Constants.UserDefaultsKeys.userId) as? Int else { return nil }
    return
      UserInfo(
        userId: userId,
        avatarURL: defaults.string(forKey: Constants.UserDefaultsKeys.avatarURL),
        userName: defaults.string(forKey: Constants.UserDefaultsKeys.userName),
        about: defaults.string(forKey: Constants.UserDefaultsKeys.about)
    )
  }
  
  func saveToDefaults() {
    let defaults = UserDefaults.standard
    defaults.set(userId, forKey: Constants.UserDefaultsKeys.userId)
    defaults.set(avatarURL, forKey: Constants.UserDefaultsKeys.avatarURL)
    defaults.set(userName, forKey: Constants.UserDefaultsKeys.userName)
    defaults.set(about, forKey: Constants.UserDefaultsKeys.about)
  }
}
