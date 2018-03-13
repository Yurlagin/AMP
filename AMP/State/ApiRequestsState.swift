//
//  ApiRequestsState.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 12.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift

struct ApiRequestsState: StateType {
  
  typealias EventTasks = (like: Cancel?, dislike: Cancel?)
  
  var eventsLikeRequests: [Int: EventTasks]
  var commentsLikeRequests: [CommentId: Cancel]
  var createEventStatus: CreateEventStatus = .none
  var setUserProfileSettingsRequest: SetUserProfileRequestStatus = .none
  
}
