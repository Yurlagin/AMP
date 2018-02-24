//
//  Comment.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 16.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import Foundation

struct Comment: Codable {
  
  var id: Int
  var userId: Int
  var userName: String?
  var avatarURL: String?
  var created: Date
  var message: String?
  var like: Bool
  var likes: Int
  var replyToId: Int?
  
  
  enum CodingKeys: String, CodingKey {
    case id = "comid"
    case userId = "userid"
    case userName = "name"
    case avatarURL = "smallavatarurl"
    case created = "comcreated"
    case message
    case like
    case likes
    case replyToId = "replyTo"
    
  }
  
}

extension Comment {
  
  init(from decoder: Decoder) throws {
    
    enum CommentDecodingError: Error {
      case error
    }

    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    id = try values.decode(Int.self, forKey: .id)
    userId = try values.decode(Int.self, forKey: .userId)
    userName = try values.decodeIfPresent(String.self, forKey: .userName)
    avatarURL = try values.decodeIfPresent(String.self, forKey: .avatarURL)
    
    let createdString = try values.decode(String.self, forKey: .created)
    guard let created = Date(ampDateString: createdString) else { throw CommentDecodingError.error }
    self.created = created
    
    message = try values.decodeIfPresent(String.self, forKey: .message)
    
    let likeInt = try values.decode(Int.self, forKey: .like)
    self.like = likeInt > 0
    
    likes = try values.decode(Int.self, forKey: .likes)
    replyToId = try values.decodeIfPresent(Int.self, forKey: .likes)
    
  }
}

extension Comment: Equatable, Hashable {
  var hashValue: Int {
    return self.created.hashValue + self.like.hashValue + self.likes.hashValue
  }
  
  static func ==(lhs: Comment, rhs: Comment) -> Bool {
    return lhs.id == rhs.id
  }
  
  
}
