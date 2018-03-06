//
//  ApiRequestsReducer.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 12.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift

func apiRequestsReducer(action: Action, state: ApiRequestsState?) -> ApiRequestsState {
  
  var state = state ?? ApiRequestsState(eventsLikeRequests: [:], commentsLikeRequests: [:], createEventStatus: .none)
  
  switch action {
    
  case _ as ReSwiftInit:
    break
    
    
  case let action as EventLikeInvertAction:
    if var cancelTasks = state.eventsLikeRequests[action.eventId] {
      cancelTasks.like = action.cancelTask
      state.eventsLikeRequests[action.eventId] = cancelTasks
    } else if let cancelFunction = action.cancelTask {
      state.eventsLikeRequests[action.eventId] = (like: cancelFunction, dislike: nil)
    }
    
    
  case let action as EventDislikeInvertAction:
    if var cancelTasks = state.eventsLikeRequests[action.eventId] {
      cancelTasks.dislike = action.cancelTask
      state.eventsLikeRequests[action.eventId] = cancelTasks
    } else if let cancelFunction = action.cancelTask {
      state.eventsLikeRequests[action.eventId] = (like: cancelFunction, dislike: nil)
    }
    
    
  case let action as EventLikeSent:
    if let _ = state.eventsLikeRequests[action.event.id] {
      state.eventsLikeRequests[action.event.id]?.like = nil
    }
    
    
  case let action as EventDislikeSent:
    if let _ = state.eventsLikeRequests[action.event.id] {
      state.eventsLikeRequests[action.event.id]?.dislike = nil
    }
    
    
  case let action as CommentLikeInvertAction:
      state.commentsLikeRequests[action.commentId] = action.cancelTask

    
  case let action as CommentLikeSent:
    state.commentsLikeRequests[action.commentId] = nil
    
    
  case let action as CreateEventStatus:
    state.createEventStatus = action
    
  default :
    break
    
  }
  
  return state
}

