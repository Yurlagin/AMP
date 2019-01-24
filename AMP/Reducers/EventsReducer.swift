//
//  EventListReducer.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 04.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift
import CoreLocation

func eventsReducer(action: Action, state: EventsState?) -> EventsState {
  
  var state = state ?? EventsState(allEvents: [:], eventListStatus: .none, settings: EventsState.Settings())
  
  func addOrReplace(newEvents: [Event]) {
    newEvents.forEach { event in
      if let _ = state.allEvents[event.id] {
        state.allEvents[event.id]?.event = event
      } else {
        state.allEvents[event.id] = EventState(event: event)
      }
    }
  }
  
  func invertLike(eventId: EventId) {
    guard var event = state.getEventBy(id: eventId) else {
      assertionFailure("We shouldn't be here")
      return
    }
    event.like = !event.like
    event.likes += event.like ? 1 : -1
    addOrReplace(newEvents: [event])
  }
  
  func invertDislike(eventId: EventId) {
    guard var event = state.getEventBy(id: eventId) else {
      assertionFailure("We shouldn't be here")
      return
    }
    event.dislike = !event.dislike
    event.dislikes += event.dislike ? 1 : -1
    addOrReplace(newEvents: [event])
  }
  
  
  switch action {
  case _ as ReSwiftInit:
    break
    
    // MARK: - Events
    
  case is LoadEventList:
    if var eventList = state.eventList {
      eventList.updatingStatus = .refreshing
    } else {
      state.eventListStatus = .loading
    }
    
  case is LoadMoreEvents:
    guard var eventList = state.eventList else {
      assertionFailure("We should not be here")
      break
    }
    eventList.updatingStatus = .loadMore
    state.eventListStatus = .done(eventList)
    
  case let action as RefreshEventsList:
    addOrReplace(newEvents: action.events)
    state.eventListStatus = .done (
      EventsState.EventList (
        location: action.location,
        eventIds: Set(action.events.map{$0.id}),
        hasMore: action.events.count <= state.settings.pageLimit,
        updatingStatus: .none
      )
    )
    
  case let action as AppendEventsToList:
    addOrReplace(newEvents: action.events)
    if var eventList = state.eventList {
      eventList.eventIds.formUnion(action.events.map{$0.id})
      eventList.updatingStatus = .none
      state.eventListStatus = .done(eventList)
    } else {
      assertionFailure("AppendEventsToList Action can be invoke when we allready have events in current list")
    }
    
  case let action as AppendEventsToMap:
    addOrReplace(newEvents: action.events)
    
  case let action as EventPostingResult:
    if case .done(let event) = action {
      addOrReplace(newEvents: [event])
    }
    
  case let action as SetEventListError:
    switch state.eventListStatus {
    case .loading:
      state.eventListStatus = .error(action.error)
      
    case .done(var eventList):
      eventList.updatingStatus = .error(action.error)
      state.eventListStatus = .done(eventList)
      
    default:
      assertionFailure("We shouldn't be here")
    }
    
  case let action as EventLikeDislikeSendingResult:
    switch action {
    case .sent(_):
      break
      
    case .error(let eventId):
      invertLike(eventId: eventId)
    }
    
  case let action as EventLikeInvertAction:
    invertLike(eventId: action.eventId)
    
  case let action as EventDislikeInvertAction:
    invertDislike(eventId: action.eventId)
    
    // MARK: - Comments
    
  case let action as LoadCommentsPage:
    state.allEvents[action.eventId]?.loadCommentsStatus = .loading
    
  case let action as DidLoadComments:
    guard var eventState = state.allEvents[action.eventId] else { break }
    var event = eventState.event
    switch action.action {
    case .append:
      event.comments?.insert(contentsOf: action.comments, at: 0)
    case .replace:
      event.comments = action.comments
    }
    eventState.event = event
    eventState.loadCommentsStatus = .none
    state.allEvents[action.eventId] = eventState
    
  case let action as LoadCommentsError:
    state.allEvents[action.eventId]?.loadCommentsStatus = .error
    
  case let action as CommentLikeInvertAction:
    guard var eventState = state.allEvents[action.eventId],
      var comments = eventState.event.comments,
      let index = comments.firstIndex(where: {$0.id == action.commentId}) else {
        break
    }
    switch action.action{
    case .addLikeComment:
      comments[index].like = true
      comments[index].likes += 1
      
    case .removeLikeComment:
      comments[index].like = false
      comments[index].likes -= 1
    }
    eventState.event.comments = comments
    state.allEvents[action.eventId] = eventState
    
  case let action as SendCommentLikeError:
    guard var eventState = state.allEvents[action.eventId],
      var comments = eventState.event.comments,
      let index = comments.firstIndex(where: {$0.id == action.commentId}) else {
        break
    }
    var comment = comments[index]
    comment.like = !comment.like
    comment.likes += comment.like ? 1 : -1
    comments[index] = comment
    eventState.event.comments = comments
    state.allEvents[action.eventId] = eventState
    
  case let action as ChangeCommentDraftText:
    state.allEvents[action.eventId]?.commentDraft.text = action.text
    
  case let action as ChangeCommentDraftType:
    state.allEvents[action.eventId]?.commentDraft.type = action.type
    
  case let action as SendComment:
    state.allEvents[action.eventId]?.commentDraft.postingState = .loading
    
  case let action as SentComment:
    guard let eventStatus = state.allEvents[action.eventId] else { break }
    var event = eventStatus.event
    if let comments = event.comments {
      var newComment = action.comment
      if let quoteId = action.comment.replyToId, let quotedComment = comments.first(where: {$0.id == quoteId}) {
        newComment.quote = CommentQuote(userName: quotedComment.userName ?? "Без Имени",
                                        message: quotedComment.message ?? "")
      }
      event.comments?.append(newComment)
    } else {
      event.comments = [action.comment]
    }
    event.commentsCount += 1
    if action.isSolution {
      event.solutionCommentId = action.comment.replyToId
    }
    state.allEvents[action.eventId] = EventState(event: event)
    
  case let action as SendCommentError:
    state.allEvents[action.eventId]?.commentDraft.postingState = .error
    
  case let action as DidShowCommentPostingError:
    state.allEvents[action.eventId]?.commentDraft.postingState = .none
    
  default:
    break
  }
  
  return state
}

extension EventsState {
  var eventList: EventList? {
    if case .done(let eventList) = self.eventListStatus {
      return eventList
    } else {
      return nil
    }
  }
}
