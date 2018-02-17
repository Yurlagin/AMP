//
//  EventListReducer.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 04.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift

func eventsReducer(action: Action, state: EventsState?) -> EventsState {
  
  var state = state ?? EventsState(list: nil, isEndOfListReached: false, settings: EventsState.Settings(), commentScreens: [:], request: .none)
  
  func updateEvent(_ event: Event) {
    if let index = state.list?.events.index(of: event) {
      state.list?.events[index] = event
    }
  }
  
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
    
  case let action as LikeEventSent:
    updateEvent(action.event)

  case let action as DislikeEventSent:
    updateEvent(action.event)

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
    
  case let action as DislikeInvertAction:
    if let index = state.list?.events.index(where: {$0.id == action.eventId}) {
      var event = state.list!.events[index]
      if event.dislike {
        event.dislikes -= 1
      } else {
        event.dislikes += 1
      }
      event.dislike = !event.dislike
      state.list?.events[index] = event
    }

  case let action as CreateCommentsScreen:
    guard state.commentScreens[action.screenId] == nil else { break }
    let comments = state.getEventBy(id: action.eventId)?.comments ?? []
    state.commentScreens[action.screenId] = EventsState.Comments(
      eventId: action.eventId,
      comments: comments,
      visibleCount: comments.count,
      isEndReached: false, // TODO: здесь должна быть настоящая проверочка
      request: .none)

  case let action as RemoveCommentsScreen:
    state.commentScreens[action.screenId] = nil

    
  default :
    break
    
  }
  
  return state
}
