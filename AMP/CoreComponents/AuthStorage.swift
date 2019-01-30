//
//  AuthStorage.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 06/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import Locksmith
import Firebase

// TODO: move FCM token to credential storage
// TODO: remove Firabase and Locksmith dependencies

protocol AuthStorage {
  func store(userCredentials: UserCredentials) throws
  func loadCredentials() -> UserCredentials?
  func deleteCredentials() throws
}

class AuthStorageImpl { }

extension AuthStorageImpl: AuthStorage {
  func store(userCredentials: UserCredentials) throws {
    try Locksmith.updateData(data: [Constants.KeyChainKeys.token: userCredentials.token],
                             forUserAccount: Constants.KeyChainKeys.userAccount)
    UserDefaults.standard.set(userCredentials.level, forKey: Constants.UserDefaultsKeys.level)
    UserDefaults.standard.set(userCredentials.phone, forKey: Constants.UserDefaultsKeys.phone)
    UserDefaults.standard.set(userCredentials.fcmTokenDelivered,
                              forKey: Constants.UserDefaultsKeys.usFCMTokenDelivered)
  }
  
  func loadCredentials() -> UserCredentials? {
    guard let data = Locksmith.loadDataForUserAccount(userAccount: Constants.KeyChainKeys.userAccount),
      let token = data[Constants.KeyChainKeys.token] as? String else { return nil }
    let fcmToken = Messaging.messaging().fcmToken
    
    return UserCredentials(
      phone: UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.phone),
      level: UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.level) as? Int ?? 0,
      token: token,
      fcmToken: fcmToken, // TODO: - Move to keychain
      fcmTokenDelivered: UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.usFCMTokenDelivered)
    )
  }
  
  func deleteCredentials() throws {
    try Locksmith.deleteDataForUserAccount(userAccount: Constants.KeyChainKeys.userAccount)
  }

}

