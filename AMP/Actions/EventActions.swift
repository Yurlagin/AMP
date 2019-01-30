//
//  EventListActions.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 04.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift
import CoreLocation

// MARK: - Event list actions

struct LoadEventList: Action {}

struct RefreshEventsList: Action {
  let location: CLLocation
  let events: [Event]
}

struct LoadMoreEvents: Action {}

struct AppendEventsToList: Action {
  let events: [Event]
  init (_ events: [Event]) {
    self.events = events
  }
}

struct SetEventListError: Action {
  let error: Error
  init (_ error: Error) {
    self.error = error
  }
}

// MARK: - Event Details Actions

struct EventLikeInvertAction: Action {
  let eventId: Int
}

struct EventDislikeInvertAction: Action {
  let eventId: Int
}

enum EventLikeDislikeSendingResult: Action {
  case sent(Event?)
  case error(EventId)
}

struct EventDislikeSent: Action {
  let event: Event
}

// MARK: - Event Map Actions

struct DidChangeMapRect: Action {
  let maxLat: Double
  let maxLon: Double
  let minLat: Double
  let minLon: Double
  let excludeEventIds: Set<EventId>
}

struct AppendEventsToMap: Action {
  let events: [Event]
}

// MARK: - Comments actions

struct LoadCommentsPage: Action {
  let eventId: EventId
  let limit: Int
  let offset: Int
  let maxId: Int?
}

struct DidLoadComments: Action {
  let eventId: EventId
  let comments: [Comment]
  let action: ActionType
  
  enum ActionType {
    case append
    case replace
  }
}

struct LoadCommentsError: Action {
  let eventId: EventId
  let error: Error
}

struct CommentLikeInvertAction: Action {
  let eventId: EventId
  let commentId: CommentId
  let action: CommentLikeAction
}

struct SendCommentLikeError: Action {
  let eventId: EventId
  let commentId: CommentId
}

struct CommentLikeSent: Action {
  let commentId: CommentId
}

struct ChangeCommentDraftType: Action {
  let eventId: EventId
  let type: CommentType
}

struct ChangeCommentDraftText: Action {
  let eventId: EventId
  let text: String
}

struct SendComment: Action {
  let eventId: EventId
}

struct SentComment: Action {
  let eventId: EventId
  let comment: Comment
  let isSolution: Bool
}

struct SendCommentError: Action {
  let eventId: EventId
  let error: Error
}

struct DidShowCommentPostingError: Action {
  let eventId: EventId
}
