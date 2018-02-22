//
//  Event.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 16.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import Foundation

struct Event: Codable {
  let id: Int
  let userName: String?
  let avatarUrl: String?
  let latitude: Double
  let longitude: Double
  let address: String?
  let message: String?
  let type: EventType
  let created: Date
  let howlong: TimeInterval
  let changed: Date?
  var commentsCount: Int
  var dislikes: Int
  var likes: Int
  var like: Bool
  var dislike: Bool
  let visible: Bool // visible=показывается всем pended= на премодерации и показывается только автору
  var comments: [Comment]?
  var maxCommentId: Int?
  
  enum EventType: String, Codable {
    case questions
    case helps
    case founds
    case chats
    case witness
    case gibdds
    case alerts
    case news
  }
  
  enum CodingKeys: String, CodingKey {
    case id
    case userName = "name"
    case avatarUrl = "smallavatarurl"
    case message
    case latitude = "lat"
    case longitude = "lon"
    case address
    case type
    case created
    case howlong
    case changed
    case like
    case likes
    case dislike
    case dislikes
    case commentsCount = "commentsnum"
    case visible = "status"
    case comments
    case maxCommentId
  }
}


extension Event {
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    id = try values.decode(Int.self, forKey: .id)
    userName = try values.decodeIfPresent(String.self, forKey: .userName)
    avatarUrl = try values.decodeIfPresent(String.self, forKey: .avatarUrl)
    message = try values.decodeIfPresent(String.self, forKey: .message)
    address =  try values.decodeIfPresent(String.self, forKey: .address)
    howlong = try values.decode(Double.self, forKey: .howlong)
    commentsCount = try values.decode(Int.self, forKey: .commentsCount)
    likes = try values.decode(Int.self, forKey: .likes)
    dislikes = try values.decode(Int.self, forKey: .dislikes)
    
    let lat = try values.decode(String.self, forKey: .latitude)
    let lon = try values.decode(String.self, forKey: .longitude)
    let typeRaw = try values.decode(String.self, forKey: .type)
    let createdString = try values.decode(String.self, forKey: .created)
    let changedString = try values.decodeIfPresent(String.self, forKey: .changed)
    let likeInt = try values.decode(Int.self, forKey: .like)
    let dislikeInt = try values.decode(Int.self, forKey: .dislike)
    let visible = try values.decode(String.self, forKey: .visible)
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    guard
      let latitude = Double(lat),
      let longitude = Double(lon),
      let type = EventType(rawValue: typeRaw),
      let created = dateFormatter.date(from: createdString)
      else {
        throw EventDecodingError.error
    }
    
    self.latitude = latitude
    self.longitude = longitude
    self.type = type
    self.created = created
    self.changed = changedString == nil ? nil : dateFormatter.date(from: changedString!)
    self.like = likeInt > 0
    self.dislike = dislikeInt > 0
    self.visible = visible == "visible"
    self.comments = try values.decodeIfPresent([Comment].self, forKey: .comments)
    self.maxCommentId = try values.decodeIfPresent(Int.self, forKey: .maxCommentId)

  }
  
  enum EventDecodingError: Error {
    case error
  }
}



extension Event: Equatable {
  static func ==(lhs: Event, rhs: Event) -> Bool {
    return lhs.id == rhs.id
  }
}

extension Event: Hashable {
  var hashValue: Int {
    return id.hashValue +
      commentsCount.hashValue +
      dislikes.hashValue +
      likes.hashValue +
      like.hashValue +
      dislike.hashValue +
      visible.hashValue
  }
}
