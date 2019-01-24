//
//  Comment.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 16.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import Foundation

typealias CommentId = Int

struct Comment {
  var id: CommentId
  var userId: Int
  var userName: String?
  var avatarURL: String?
  var created: Date
  var message: String?
  var like: Bool
  var likes: Int
  var replyToId: CommentId?
  var quote: CommentQuote?
}

extension Comment: Codable {
  
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
    
    let likeInt = try values.decodeIfPresent(Int.self, forKey: .like)
    self.like = (likeInt ?? 0) > 0
    
    likes = try values.decodeIfPresent(Int.self, forKey: .likes) ?? 0
    replyToId = try values.decodeIfPresent(Int.self, forKey: .replyToId)
  }
}

extension Comment: Hashable {}
