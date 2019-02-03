//
//  Constants.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 05/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import Foundation

enum Constants { }

extension Constants {
  
  static var baseURL: String? {
    return Bundle.main.object(forInfoDictionaryKey: Constants.PListKeys.BaseURL) as? String
  }
  
  enum UserDefaultsKeys {
    static let fcmToken = "fcmToken"
    static let userId = "userId"
    static let avatarURL = "avatarURL"
    static let email = "email"
    static let level = "level"
    static let userName = "name"
    static let phone = "phone"
    static let about = "about"
    static let usFCMTokenDelivered = "fcmTokenDelivered"
  }
  
  enum PListKeys {
    static let BaseURL = "BaseURL"
  }
  
  enum KeyChainKeys {
    static let userAccount = "AMP"
    static let token = "token"
  }
  
}
