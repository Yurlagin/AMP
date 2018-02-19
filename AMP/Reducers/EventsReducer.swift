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
  
  func updateEventCounters(fromNewEvent event: Event) {
    if let index = state.list?.events.index(of: event) {
      var oldEvent = state.list!.events[index]
      oldEvent.like = event.like
      oldEvent.likes = event.likes
      oldEvent.dislike = event.dislike
      oldEvent.dislikes = event.dislikes
      oldEvent.commentsCount = event.commentsCount
      state.list!.events[index] = oldEvent
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
    updateEventCounters(fromNewEvent: action.event)

  case let action as DislikeEventSent:
    updateEventCounters(fromNewEvent: action.event)

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
      comments: [],
      eventId: action.eventId,
      visibleCount: comments.count,
      isEndReached: false, // TODO: здесь должна быть настоящая проверочка
      request: .none)

  case let action as RemoveCommentsScreen:
    state.commentScreens[action.screenId] = nil
    
  case let action as NewComments:
    guard var screen = state.commentScreens[action.screenId] else { break }
    
    switch action.action {
    case .append: screen.comments.insert(contentsOf: action.comments, at: 0)
    case .replace: screen.comments = action.comments
    }
    
    screen.isEndReached = action.comments.count < screen.pageLimit
   
    state.commentScreens[action.screenId] = screen

    
  default :
    break
    
  }
  
  return state
}
