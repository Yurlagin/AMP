//
//  Requests.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 19.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import Foundation


struct EventListRequest: Codable {
  
  let action = "getEventsList"
  var filter: Filter
  let token: String
  
  struct Filter: Codable {
    var lat: Double
    var lon: Double
    var eventsradius: Int = 20
    var exclude : [String] = []
    var sort = "create"
    var tzone: String = "+07:00"
    var onlyactive: Bool = true
    var text: String = ""
    var onlymine = false
    
    var helps: Bool = true
    var founds: Bool = true
    var chats: Bool = true
    var witness: Bool = true
    var gibdds: Bool = true
    var alerts: Bool = true
    var news: Bool = true
    var questions: Bool = true
    
    var maxId: Int?
    var limit: Int = 0
    var offset: Int = 0
    
    init(lat: Double, lon: Double) {
      self.lat = lat
      self.lon = lon
    }
  }
}


struct LikeEventRequest: Encodable {
  let token: String
  let action: RequestType
  let eventid: EventId
  
  enum RequestType: String, Encodable {
    case addLike
    case removeLike
    case addDisLike
    case removeDisLike
  }
}


struct LikeCommentRequest: Encodable {
  let token: String
  let action: RequestType
  let id: Int
  
  enum RequestType: String, Encodable {
    case addLikeComment
    case removeLikeComment
  }
}


struct DefaultAnswer: Decodable {
  let answer: String
}


struct CommentsRequest: Codable {
  let action = "getComments"
  let eventid: EventId
  let token: String
  let filter: CommentsFilter
  
  struct CommentsFilter: Codable {
    let limit: Int
    let offset: Int
    let maxid: Int?
  }
}

struct EventRequest: Codable {
  let action = "getEvent"
  let eventid: EventId
  let token: String
  let filter: Filter
  
  struct Filter: Codable {
    let tzone = "+07:00"
  }
}


struct CommentsResponse: Codable {
  let answer: String
  let comments: [Comment]?
  let replyedComments: [Comment]?
}


struct AddCommentRequest: Codable {
  let action = "addComment"
  let comment: String
  let eventid: EventId
  let token: String
  let replyTo: CommentId?
  let thank: Bool?
}


extension EventListRequest: CustomStringConvertible {
  
  var description: String {
    let mirror = Mirror(reflecting: self)
    return mirror.description
  }
}
