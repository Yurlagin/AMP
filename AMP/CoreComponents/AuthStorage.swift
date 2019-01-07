//
//  AuthStorage.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 06/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import Locksmith
import PromiseKit
import Firebase

// TODO: dive to credential and user profile storages
// TODO: move FCM token to credential storage
// TODO: remove Firabase and Locksmith dependencies

protocol AuthStorage {
  func store(userCredentials: UserCredentials) -> Promise<UserCredentials>
  func loadCredentials() -> UserCredentials?
  func deleteCredentials() throws
}

class AuthStorageImpl { }

extension AuthStorageImpl: AuthStorage {
  func store(userCredentials: UserCredentials) -> Promise<UserCredentials> {
    return Promise { (fulfill, error) in
      
      try Locksmith.updateData(data: [Constants.KeyChainKeys.tokenKey: userCredentials.token],
                               forUserAccount: Constants.KeyChainKeys.userAccount)
      UserDefaults.standard.set(userCredentials.avaurl, forKey: Constants.UserDefaultsKeys.avatarURLKey)
      UserDefaults.standard.set(userCredentials.email, forKey: Constants.UserDefaultsKeys.emailKey)
      UserDefaults.standard.set(userCredentials.level, forKey: Constants.UserDefaultsKeys.levelKey)
      UserDefaults.standard.set(userCredentials.name, forKey: Constants.UserDefaultsKeys.nameKey)
      UserDefaults.standard.set(userCredentials.phone, forKey: Constants.UserDefaultsKeys.phoneKey)
      UserDefaults.standard.set(userCredentials.about, forKey: Constants.UserDefaultsKeys.aboutKey)
      UserDefaults.standard.set(userCredentials.fcmTokenDelivered,
                                forKey: Constants.UserDefaultsKeys.fcmTokenDeliveredKey)
      
      fulfill(userCredentials)
    }
  }
  
  func loadCredentials() -> UserCredentials? {
    guard let data = Locksmith.loadDataForUserAccount(userAccount: Constants.KeyChainKeys.userAccount),
      let token = data[Constants.KeyChainKeys.tokenKey] as? String else { return nil }
    let fcmToken = Messaging.messaging().fcmToken
    
    return UserCredentials(phone: UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.phoneKey),
                           name: UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.nameKey),
                           email: UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.emailKey),
                           level: UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.levelKey)
                            as? Int ?? 0,
                           avaurl: UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.avatarURLKey),
                           about: UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.aboutKey),
                           token: token,
                           fcmToken: fcmToken,
                           fcmTokenDelivered: UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.fcmTokenDeliveredKey))
  }
  
  func deleteCredentials() throws {
    try Locksmith.deleteDataForUserAccount(userAccount: Constants.KeyChainKeys.userAccount)
  }

}

