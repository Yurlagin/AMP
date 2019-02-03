//
//  Parser.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 03.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import PromiseKit

struct AmpFirAuthCredentialsResponse: Decodable {
  let answer: String
  let info: UserCredentials?
}

struct UserCredentials: Decodable {
  let phone: String?
  let level: Int
  let token: String
  var fcmToken: String?
  var fcmTokenDelivered: Bool?
}

struct EventsAnswer: Decodable {
  let answer: String
  let events: [Event]?
  let maxId: Int?
  let maxCommentId: Int?
}

enum Parser {
  
  private static func userInfoFrom(data: Data) -> UserInfo? {
    
    guard let rootDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
      let userSettingsDictArray = rootDict?["userSettings"] as? [[String: Any]],
      let userIdDict = userSettingsDictArray.first(where: { $0["key"] as? String == "userid"}),
      let userIdString = userIdDict["value"] as? String,
      let userId = Int(userIdString)
    else {
      return nil
    }
    return
      UserInfo(
        userId: userId,
        avatarURL: userSettingsDictArray.first(where: { $0["key"] as? String == "smallavatarurl"})?["value"] as? String,
        userName: userSettingsDictArray.first(where: { ($0["key"] as? String) == "username" })?["value"] as? String,
        about: userSettingsDictArray.first(where: { ($0["key"] as? String) == "about" })?["value"] as? String)
  }
  
  static func ampUser(data: Data) -> Promise<(UserCredentials, UserInfo)> {
    return Promise(resolvers: { (resolve, error) in
      let decoder = JSONDecoder()
      let credentialsResponse = try decoder.decode(AmpFirAuthCredentialsResponse.self, from: data)
      if let credentials = credentialsResponse.info, let userInfo = userInfoFrom(data: data) {
        resolve((credentials, userInfo))
      } else {
        error(ApiError.parsingError(underlyingError: nil))
      }
    })
  }
  
  static func parse<T: Decodable>(_ data: Data) -> Promise<T> {
    return Promise { (resolve, error) in
      let decodedStruct = try JSONDecoder().decode(T.self, from: data)
      resolve(decodedStruct)
    }
  }
  
  static func parseEventList(data: Data) -> Promise<[Event]> {
    return Promise { (resolve, error) in
      let answer = try JSONDecoder().decode(EventsAnswer.self, from: data)
      if let events = answer.events {
        resolve(events)
      } else {
        error(ApiError.parsingError(underlyingError: nil))
      }
    }
  }
  
}
