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
    static let fcmTokenKey = "fcmToken"
    static let avatarURLKey = "avatarURL"
    static let emailKey = "email"
    static let levelKey = "level"
    static let nameKey = "name"
    static let phoneKey = "phone"
    static let aboutKey = "about"
    static let fcmTokenDeliveredKey = "fcmTokenDelivered"
  }
  
  enum PListKeys {
    static let BaseURL = "BaseURL"
  }
  
  enum KeyChainKeys {
    static let userAccount = "AMP"
    static let tokenKey = "token"
  }
  
}
