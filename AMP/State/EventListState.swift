//
//  EventListState.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 04.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift
import CoreLocation

struct EventListState: StateType {
  
  var list: (location: CLLocation, events: [Event])?

  var request: RequestStatus
  
  enum RequestStatus {
    case none
    case request(RequestType)
    case error(Error)
    case success([Event])
    
    enum RequestType {
      case refresh
      case loadMore
    }
  }
}

struct Event: Codable {
  let id: Int
  let userName: String
  let avatarUrl: String?
  let message: String
  let latitude: Double
  let longitude: Double
  let type: EventType
  let created: Date
  let howlong: TimeInterval
  let changed: Date?
  let commentsCount: Int
  let dislikes: Int
  let likes: Int
  let like: Bool
  let dislike: Bool
  let address: String
  let visible: Bool // visible=показывается всем pended= на премодерации и показывается только автору
  
  enum EventType: String, Codable {
    case events
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
    case type
    case created
    case howlong
    case changed
    case commentsCount = "commentsnum"
    case dislikes
    case likes
    case like
    case dislike
    case address
    case visible = "status"
  }
}


extension Event {
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    id = try values.decode(Int.self, forKey: .id)
    userName = try values.decode(String.self, forKey: .userName)
    avatarUrl = try values.decode(String.self, forKey: .avatarUrl)
    message = try values.decode(String.self, forKey: .message)
    address =  try values.decode(String.self, forKey: .address)
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
    
  }
  
  enum EventDecodingError: Error {
    case error
  }
}



