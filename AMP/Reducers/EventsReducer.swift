//
//  EventListReducer.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 04.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift

func eventsReducer(action: Action, state: EventsState?) -> EventsState {
  
  var state = state ?? EventsState(list: nil, map: [], isEndOfListReached: false, settings: EventsState.Settings(), eventScreens: [:], listRequest: .none)
  
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
    
    if let index = state.map.index(of: event) {
      var newEvent = state.map[index]
      newEvent.like = event.like
      newEvent.likes = event.likes
      newEvent.dislike = event.dislike
      newEvent.dislikes = event.dislikes
      newEvent.commentsCount = event.commentsCount
      state.map[index] = newEvent
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
    
    
  case let action as AppendEventsToMap:
    action.events.forEach{
      if let index = state.map.index(of: $0) {
        state.map[index] = $0
      } else {
        state.map.append($0)
      }
    }
    
    
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
    if let index = state.map.index(where: {$0.id == action.eventId}) {
      var event = state.map[index]
      if event.like {
        event.likes -= 1
      } else {
        event.likes += 1
      }
      event.like = !event.like
      state.map[index] = event
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
    if let index = state.map.index(where: {$0.id == action.eventId}) {
      var event = state.map[index]
      if event.dislike {
        event.dislikes -= 1
      } else {
        event.dislikes += 1
      }
      event.dislike = !event.dislike
      state.map[index] = event
    }
    

  case let action as CreateCommentsScreen:
    guard state.eventScreens[action.screenId] == nil else { break }
    state.eventScreens[action.screenId] = EventsState.EventScreen(
      comments: [],
      replyedComments: [:],
      eventId: action.eventId,
      isEndReached: false, // TODO: здесь должна быть настоящая проверочка
      fetchCommentsRequest: .run,
      sendCommentRequest: .none,
      outgoingCommentId: nil,
      textInputMode: .new)
    
    
  case let action as GetCommentsPage:
    state.eventScreens[action.screenId]?.fetchCommentsRequest = .run
    print(action)
    
    
  case let action as GetCommentsError:
    state.eventScreens[action.screenId]?.fetchCommentsRequest = .error(action.error)


  case let action as RemoveCommentsScreen:
    state.eventScreens[action.screenId] = nil
    
    
  case let action as GotEvent:
    if let index = state.list?.events.index(of: action.event) {
      state.list?.events[index] = action.event
    }
    
    state.eventScreens[action.screenId]?.comments = action.event.comments ?? []
    action.event.replyedComments?.forEach{ state.eventScreens[action.screenId]?.replyedComments[$0.id] = $0 }
    
    state.eventScreens[action.screenId]?.fetchCommentsRequest = .none
    state.eventScreens[action.screenId]?.isEndReached = (action.event.comments?.count ?? 0) == action.event.commentsCount
    
    
  case let action as NewComments:
    guard var screen = state.eventScreens[action.screenId] else { break }
    
    switch action.action {
    case .append: screen.comments.insert(contentsOf: action.comments, at: 0)
    case .replace: screen.comments = action.comments
    }
    
    action.replyedComments.forEach{screen.replyedComments[$0.id] = $0}

    screen.isEndReached = action.comments.count < state.settings.commentPageLimit
    screen.fetchCommentsRequest = .none
    
    state.eventScreens[action.screenId] = screen

    
  case let action as CommentLikeInvertAction:
    
    func invertLike(eventId: EventId, commentId: CommentId, screens: [ScreenId: EventsState.EventScreen]) -> [ScreenId: EventsState.EventScreen] {
      return state.eventScreens.mapValues { (screen) in
        guard eventId == screen.eventId else { return screen }
        var screen = screen
        if let index = screen.comments.index(where: { $0.id == commentId }) {
          var comment = screen.comments[index]
          if comment.like { comment.likes -= 1 } else { comment.likes += 1 }
          comment.like = !comment.like
          screen.comments[index] = comment
        }
        return screen
      }
    }
    
    state.eventScreens = invertLike(eventId: action.eventId, commentId: action.commentId, screens: state.eventScreens)
  
    
  case let action as SendComment:
    state.eventScreens[action.screenId]?.sendCommentRequest = .run
    state.eventScreens[action.screenId]?.outgoingCommentId = action.localId
  
    
  case let action as SentComment:
    
    let eventListIndex = state.list?.events.index(where: { $0.id == action.eventId })
    let eventMapIndex = state.map.index(where: { $0.id == action.eventId })
    
    if let eventIndex = eventListIndex {
      state.list?.events[eventIndex].commentsCount += 1
    }
    
    if let eventIndex = eventMapIndex {
      state.map[eventIndex].commentsCount += 1
    }
    
    state.eventScreens = state.eventScreens.mapValues { screen in
      guard screen.eventId == action.eventId else { return screen }
      var screen = screen
      var postedComment = action.comment
      
      func addCommentToReplyedComments(commentId: CommentId) {
        guard let commentIndex = screen.comments.index(where: {$0.id == commentId}) else { return }
        screen.replyedComments[commentId] = screen.comments[commentIndex]
      }

      
      if screen.outgoingCommentId == action.localId {
        screen.outgoingCommentId = nil
        screen.sendCommentRequest = .success
        if case .resolve(let commentId) = screen.textInputMode  {
          if let index = eventListIndex {
            state.list?.events[index].solutionCommentId = commentId
            postedComment.replyToId = commentId
            addCommentToReplyedComments(commentId: commentId)
          }

          if let index = eventMapIndex {
            state.map[index].solutionCommentId = commentId
            postedComment.replyToId = commentId
            addCommentToReplyedComments(commentId: commentId)
          }

        } else  if case .answer(let commentId) = screen.textInputMode {
          postedComment.replyToId = commentId
          addCommentToReplyedComments(commentId: commentId)
        }
        
        screen.textInputMode = .new
      }
      
      screen.comments.append(postedComment)
      return screen
    }

    
  case let action as SendCommentError:
    state.eventScreens = state.eventScreens.mapValues { screen in
      guard screen.eventId == action.eventId, screen.outgoingCommentId == action.localId else { return screen }
      var newScreen = screen
      newScreen.outgoingCommentId = nil
      newScreen.sendCommentRequest = .error(action.error)
      return newScreen
    }
    
  
  case let action as NewCommentShown:
    state.eventScreens[action.screenId]?.sendCommentRequest = .none
    
    
  case let action as SetCommentType:
    state.eventScreens[action.screenId]?.textInputMode = action.type
    
    
  default:
    break
    
  }
  
  
  return state
}
