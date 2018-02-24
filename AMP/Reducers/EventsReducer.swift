//
//  EventListReducer.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 04.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift

func eventsReducer(action: Action, state: EventsState?) -> EventsState {
  
  var state = state ?? EventsState(list: nil, isEndOfListReached: false, settings: EventsState.Settings(), commentScreens: [:], listRequest: .none)
  
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
    state.listRequest = action.status
    
    
  case let action as RefreshEventsList:
    state.list = (action.location, action.events)
    state.listRequest = .none
    state.isEndOfListReached = action.events.count < state.settings.pageLimit
    
    
  case let action as AppendEventsToList:
    state.list?.events.append(contentsOf: action.events)
    state.listRequest = .none
    state.isEndOfListReached = action.events.count < state.settings.pageLimit
    
    
  case let action as SetEventListError:
    state.listRequest = .error(action.error)
    
  case let action as EventLikeSent:
    updateEventCounters(fromNewEvent: action.event)
    

  case let action as EventDislikeSent:
    updateEventCounters(fromNewEvent: action.event)
    

  case let action as EventLikeInvertAction:
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
    
    
  case let action as EventDislikeInvertAction:
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
    state.commentScreens[action.screenId] = EventsState.Comments(
      comments: [],
      eventId: action.eventId,
      isEndReached: false, // TODO: здесь должна быть настоящая проверочка
      request: .run)
    
    
  case let action as GetCommentsPage:
    state.commentScreens[action.screenId]?.request = .run
    print(action)
    
    
  case let action as GetCommentsError:
    state.commentScreens[action.screenId]?.request = .error(action.error)


  case let action as RemoveCommentsScreen:
    state.commentScreens[action.screenId] = nil
    
    
  case let action as GotEvent:
    if let index = state.list?.events.index(of: action.event) {
      state.list?.events[index] = action.event
    }
    
    
    state.commentScreens[action.screenId]?.comments = action.event.comments ?? []
    state.commentScreens[action.screenId]?.request = .none
    state.commentScreens[action.screenId]?.isEndReached = (action.event.comments?.count ?? 0) == action.event.commentsCount
    
  case let action as NewComments:
    guard var screen = state.commentScreens[action.screenId] else { break }
    
    switch action.action {
    case .append: screen.comments.insert(contentsOf: action.comments, at: 0)
    case .replace: screen.comments = action.comments
    }
    
    screen.isEndReached = action.comments.count < state.settings.commentPageLimit
    screen.request = .none
    
    state.commentScreens[action.screenId] = screen

    
  case let action as CommentLikeInvertAction:
    
    func invertLike(eventId: EventId, commentId: CommentId, screens: [ScreenId: EventsState.Comments]) -> [ScreenId: EventsState.Comments] {
      return state.commentScreens.mapValues { (comments) in
        guard eventId == comments.eventId else { return comments }
        var comments = comments
        if let index = comments.comments.index(where: { $0.id == commentId }) {
          var comment = comments.comments[index]
          if comment.like { comment.likes -= 1 } else { comment.likes += 1 }
          comment.like = !comment.like
          comments.comments[index] = comment
        }
        return comments
      }
    }
    
    state.commentScreens = invertLike(eventId: action.eventId, commentId: action.commentId, screens: state.commentScreens)
  
    
  default :
    break
    
  }
  
  
  return state
}
