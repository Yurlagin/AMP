//
//  EventSideEffects.swift
//  AMP
//
//  Created by local admin on 22/02/2018.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift

func eventsEffects(eventsService: EventsServiceProtocol) -> MiddlewareItem {
  return { (action: Action, dispatch: @escaping DispatchFunction) in
    
    switch action {

    case let action as CreateCommentsScreen:
      guard let token = store.state.authState.loginStatus.getUserCredentials()?.token else { return }
      eventsService.makeRequest(EventRequest(eventid: action.eventId, token: token, filter: EventRequest.Filter()))
        .then {
          dispatch(GotEvent(event: $0, screenId: action.screenId))
        }
        .catch {
          dispatch(GetCommentsError(screenId: action.screenId, error: $0)) }
      
      
    case let action as GetCommentsPage:
      guard let token = store.state.authState.loginStatus.getUserCredentials()?.token else { return }
      eventsService.makeRequest(CommentsRequest(
        eventid: action.eventId,
        token: token,
        filter: CommentsRequest.CommentsFilter(limit: action.limit,
                                               offset: action.offset,
                                               maxid: action.maxId)))
        .then {
          dispatch(NewComments(screenId: action.screenId, comments: $0, action: .append)) }
        .catch { error in
          print (error)
          dispatch(GetCommentsError(screenId: action.screenId, error: error)) }

    
    case let action as SendComment:
      guard let token = store.state.authState.loginStatus.getUserCredentials()?.token else { return }

      var replay: Int?
      var thank: Bool?
      if case .answer(let replayId) = action.type {
        replay = replayId
      } else if case .resolve (let replayId) = action.type {
        replay = replayId; thank = true
      }
      
      eventsService.make(AddCommentRequest(comment: action.message,
                                           eventid: action.eventId,
                                           token: token,
                                           replyTo: replay,
                                           thank: thank))
        .then {
          dispatch(SentComment(localId: action.localId, eventId: action.eventId, comment: $0 ))
        } .catch {
          dispatch(SendCommentError(localId: action.localId, eventId: action.eventId, error: $0 ))
      }
      
    default:
      break
      
    }
    
  }
  
}
