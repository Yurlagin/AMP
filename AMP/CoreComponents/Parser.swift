//
//  Parser.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 03.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import PromiseKit

struct AmpFirAuthAnswer: Codable {
  let answer: String
  let info: UserCredentials?
}

struct UserCredentials: Codable {
  let phone: String?
  var name: String?
  let email: String?
  let level: Int
  let avaurl: String?
  var about: String?
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
  
  static func ampUser(data: Data) -> Promise<UserCredentials> {
    return Promise(resolvers: { (resolve, error) in
      let answer = try JSONDecoder().decode(AmpFirAuthAnswer.self, from: data)
      if let userCredentials = answer.info {
        resolve(userCredentials)
      } else {
        error(ApiError.parsingError)
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
        error(ApiError.parsingError)
      }
    }
  }
  
}
