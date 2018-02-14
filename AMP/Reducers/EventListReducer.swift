//
//  EventListReducer.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 04.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift

func eventListReducer(action: Action, state: EventListState?) -> EventListState {
  
  var state = state ?? EventListState(list: nil, isEndOfListReached: false, settings: EventListState.Settings(), request: .none)
  
  switch action {
    
  case _ as ReSwiftInit:
    break
    
  case let action as SetEventListRequestStatus:
    state.request = action.status
    
  case let action as RefreshEventsList:
    state.list = (action.location, action.events)
    state.request = .none
    state.isEndOfListReached = action.events.count < state.settings.pageLimit
    
  case let action as AppendEventsToList:
    state.list?.events.append(contentsOf: action.events)
    state.request = .none
    state.isEndOfListReached = action.events.count < state.settings.pageLimit
    
  case let action as UpdateEvent:
    if let index = state.list?.events.index(of: action.event) {
      state.list?.events[index] = action.event
    }
    
  case let action as LikeInvertAction:
    if let index = state.list?.events.index(where: {$0.id == action.eventId}) {
      var event = state.list!.events[index]
      if event.like {
        event.likes -= 1
      } else {
        event.likes += 1
      }
      event.like = !event.like
      state.list?.events[index] = event
    }

  default :
    break
    
  }
  
  return state
}
