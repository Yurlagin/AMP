//
//  EventListActions.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 04.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift
import CoreLocation

struct AppendEventsToList: Action {
  let events: [Event]
  init (_ events: [Event]) {
    self.events = events
  }
}

struct RefreshEventsList: Action {
  let location: CLLocation
  let events: [Event]
}

struct SetEventListError: Action {
  let error: Error
  init (_ error: Error) {
    self.error = error
  }
}

struct AppendEventsToMap: Action {
  let events: [Event]
}

struct SetEventListRequestStatus: Action {
  let status: EventsState.RequestStatus
  init (_ status: EventsState.RequestStatus) { self.status = status }
}

struct EventLikeInvertAction: Action {
  let eventId: Int
  let cancelTask: (()->())?
}

struct EventDislikeInvertAction: Action {
  let eventId: Int
  let cancelTask: (()->())?
}

struct EventLikeSent: Action {
  let event: Event
}

struct EventDislikeSent: Action {
  let event: Event
}

struct CreateCommentsScreen: Action {
  let screenId: ScreenId
  let eventId: EventId
}


struct RemoveCommentsScreen: Action {
  let screenId: ScreenId
}


struct GetCommentsPage: Action {
  let screenId: ScreenId
  let eventId: EventId
  let limit: Int
  let offset: Int
  let maxId: Int?
}


struct GotEvent: Action {
  let event: Event
  let screenId: ScreenId
}


struct NewComments: Action {
  let screenId: ScreenId
  let comments: [Comment]
  let replyedComments: [Comment]
  let action: ActionType
  
  enum ActionType {
    case append
    case replace
  }
}

struct GetCommentsError: Action {
  let screenId: ScreenId
  let error: Error
}

// MARK: Comment like actions

typealias CommentId = Int

struct CommentLikeInvertAction: Action {
  let eventId: EventId
  let commentId: CommentId
  let cancelTask: (()->())?
}

struct CommentLikeSent: Action {
  let commentId: CommentId
}

struct SendComment: Action {
  let screenId: ScreenId
  let eventId: EventId
  let localId: String
  let message: String
  let type: CommentType
}

struct SentComment: Action {
  let localId: String
  let eventId: EventId
  let comment: Comment
}

struct SendCommentError: Action {
  let localId: String
  let eventId: EventId
  let error: Error
}

struct NewCommentShown: Action  {
  let screenId: ScreenId
}

struct SetCommentType: Action {
  let screenId: ScreenId
  let type: CommentType
}


enum CreateEventStatus: Action {
  case none
  case run(cancelFunction: Cancel)
  case error(Error)
  case success(Event)
}

