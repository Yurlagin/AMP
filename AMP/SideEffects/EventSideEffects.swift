//
//  EventSideEffects.swift
//  AMP
//
//  Created by local admin on 22/02/2018.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift

enum EventsSideEffects {}

extension EventsSideEffects {
  static func eventsEffects(eventsService: ApiService) -> MiddlewareItem {
    return { (action: Action, dispatch: @escaping DispatchFunction) in
      switch action {
        
        // MARK: - Event Actions
        
      case let action as EventLikeInvertAction:
        store.dispatch { (state, store) -> Action? in
          guard let event = state.eventsState.getEventBy(id: action.eventId) else {
            assertionFailure("we should not be here")
            return nil
          }
          guard let token = state.authState.loginStatus.userCredentials?.token else {  return SetLoginState(.none)  }
          let likeRequest = LikeEventRequest(
            token: token,
            action: event.like ? .removeLike : .addLike,
            eventid: event.id
          )
          eventsService
            .sendEventLikeDislike(likeRequest)
            .then { dispatch(EventLikeDislikeSendingResult.sent($0)) }
            .catch { _ in dispatch(EventLikeDislikeSendingResult.error(event.id)) }
          return nil
        }
        
      case let action as EventDislikeInvertAction:
        store.dispatch { (state, store) -> Action? in
          guard let event = state.eventsState.getEventBy(id: action.eventId) else {
            assertionFailure("we should not be here")
            return nil
          }
          guard let token = state.authState.loginStatus.userCredentials?.token else {  return SetLoginState(.none)  }
          let likeRequest = LikeEventRequest(
            token: token,
            action: event.dislike ? .removeDisLike : .addDisLike,
            eventid: event.id
          )
          eventsService
            .sendEventLikeDislike(likeRequest)
            .then { dispatch(EventLikeDislikeSendingResult.sent($0)) }
            .catch { _ in dispatch(EventLikeDislikeSendingResult.error(event.id)) }
          return nil
        }
        
      case is PostEvent:
        store.dispatch{ (state, store) in
          guard let token = state.authState.loginStatus.userCredentials?.token else { return nil }
          let draft = state.createEventState.draft
          eventsService.postEvent(CreateEventRequest(
            event: CreateEventRequest.CreateEventParams(
              howlong: draft.howLong,
              lat: draft.lat,
              lon: draft.long,
              message: draft.message,
              type: draft.type),
            token: token)
            ).then {
              store.dispatch(EventPostingResult.done(newEvent: $0))
            }.catch {
              store.dispatch(EventPostingResult.error($0))
          }
          return nil
        }
        
      case is CancelPostingEvent:
        eventsService.cancelPostingEvent()
        
        // MARK: - Comment Actions
        
      case let action as LoadCommentsPage:
        guard let token = store.state.authState.loginStatus.userCredentials?.token else { return }
        eventsService
          .getComments(
            CommentsRequest(
              eventid: action.eventId,
              token: token,
              filter: CommentsRequest.CommentsFilter(
                limit: action.limit,
                offset: action.offset,
                maxid: action.maxId
              )
            )
          ).then {
            dispatch(DidLoadComments(
              eventId: action.eventId,
              comments: $0,
              action: .append))
          }.catch { error in
            dispatch(LoadCommentsError(eventId: action.eventId, error: error)) }
        
      case let action as SendComment:
        guard let token = store.state.authState.loginStatus.userCredentials?.token else { break }
        guard let eventState = store.state.eventsState.allEvents[action.eventId] else { break }
        var replay: Int?
        var thank: Bool?
        let draft = eventState.commentDraft
        if case .answer(let replayId) = draft.type {
          replay = replayId
        } else if case .resolve (let replayId) = draft.type {
          replay = replayId
          thank = true
        }
        
        let request = AddCommentRequest(
          comment: draft.text,
          eventid: action.eventId,
          token: token,
          replyTo: replay,
          thank: thank
        )
        
        eventsService.postComment(request)
          .then {
            dispatch(SentComment(eventId: action.eventId, comment: $0, isSolution: thank == true ))
          }.catch {
            dispatch(SendCommentError(eventId: action.eventId, error: $0 ))
        }
        
      case let action as CommentLikeInvertAction:
        guard let token = store.state.authState.loginStatus.userCredentials?.token else { break }
        eventsService.sendCommentLikeDislike(LikeCommentRequest(
          token: token,
          action: action.action,
          id: action.commentId
        )).catch { _ in
          dispatch(SendCommentLikeError(eventId: action.eventId, commentId: action.commentId))
        }
        
        // MARK: - Map Actions
        
      case let action as DidChangeMapRect:
        guard let token = store.state.authState.loginStatus.userCredentials?.token else { break }
        
        let excludingTypes = store.state.eventsState.settings.excludingTypes
        let startDate = Date().addingTimeInterval(-EventsMapViewModel.filterInterval)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let filter = EventsMapRequest.Filter(
          maxLon: action.maxLon,
          maxLat: action.maxLat,
          minLon: action.minLon,
          minLat: action.minLat,
          fromDate: formatter.string(from: startDate),
          exclude: Array(action.excludeEventIds.map(String.init)),
          tzone: "+07:00",
          onlyactive: false,
          onlymine: false,
          helps: !excludingTypes.contains(.helps),
          founds: !excludingTypes.contains(.founds),
          chats: !excludingTypes.contains(.chats),
          witness: !excludingTypes.contains(.witness),
          gibdds: !excludingTypes.contains(.gibdds),
          alerts: !excludingTypes.contains(.alerts),
          news: !excludingTypes.contains(.news),
          questions: !excludingTypes.contains(.questions))
        
        let request = EventsMapRequest(filter: filter, token: token)
        eventsService.getEventsForMap(request: request)
          .then {
            store.dispatch(AppendEventsToMap(events: $0))
          }.catch { (error) in
            print(error)
        }
        
      default:
        break
      }
    }
  }
}

