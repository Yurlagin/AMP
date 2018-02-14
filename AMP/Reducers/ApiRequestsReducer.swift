//
//  ApiRequestsReducer.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 12.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift

func apiRequestsReducer(action: Action, state: ApiRequestsState?) -> ApiRequestsState {
  
  var state = state ?? ApiRequestsState(likeRequests: [:])
  
  switch action {
    
  case _ as ReSwiftInit:
    break
    
  case let action as LikeInvertAction:
    if var cancelTasks = state.likeRequests[action.eventId] {
      cancelTasks.like = action.cancelTask
      state.likeRequests[action.eventId] = cancelTasks
    } else if let cancelFunction = action.cancelTask {
      state.likeRequests[action.eventId] = (like: cancelFunction, dislike: nil)
    }
    
  case let action as DislikeInvertAction:
    if var cancelTasks = state.likeRequests[action.eventId] {
      cancelTasks.dislike = action.cancelTask
      state.likeRequests[action.eventId] = cancelTasks
    } else if let cancelFunction = action.cancelTask {
      state.likeRequests[action.eventId] = (like: cancelFunction, dislike: nil)
    }
    
  case let action as UpdateEvent:
    if let _ = state.likeRequests[action.event.id] {
      if action.removeLikeTask {
        state.likeRequests[action.event.id]?.like = nil
      }
      if action.removeDislikeTask {
        state.likeRequests[action.event.id]?.dislike = nil
      }
    }
    
  default :
    break
    
  }
  
  return state
}

