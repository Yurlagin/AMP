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

struct AmpFirAuthUserInfoResponse: Decodable { // TODO: - refactor this shit =]
  let answer: String
  let info: UserInfo?
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
  
  static func ampUser(data: Data) -> Promise<(UserCredentials, UserInfo)> {
    return Promise(resolvers: { (resolve, error) in
      let decoder = JSONDecoder()
      let credentialsResponse = try decoder.decode(AmpFirAuthCredentialsResponse.self, from: data)
      let userInfoResponse = try decoder.decode(AmpFirAuthUserInfoResponse.self, from: data)
      if let credentials = credentialsResponse.info, let userInfo = userInfoResponse.info {
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
