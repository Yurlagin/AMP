//
//  EventViewModel.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 15.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import CoreLocation
import ReSwift

struct EventViewModel {
  
  let event: Event
  let screenId: ScreenId
  let comments: [Comment]
  let replyedComments: [CommentId: Comment]
  let loadMoreButtonState: LoadMoreState
  let shouldDisplayHUD: Bool
  let shouldShowPostedComment: () -> Bool
  let onDeinitScreen: (ScreenId) -> ()
  let distance: String
  let getMapURL: (CGFloat, CGFloat) -> URL?
  let didTapLike: () -> ()
  let didTapDislike: () -> ()
  let didTapLoadMore: () -> ()
  let getActionsForComment: (_ commentIndex: Int) -> [CommentAction]
  let didTapCommentAction: (CommentAction, _ commentIndex: Int) -> ()
  let didTapSendComment: (String) -> ()
  let didTapClearQoute: () -> ()
  
  enum CommentAction {
    case like
    case dislike
    case resolve
    case answer
  }
  
  enum LoadMoreState {
    case none
    case showButton
    case showLoading
    case showButtonWithError
  }
  
  init? (eventId: EventId, screenId: ScreenId, state: AppState) {
    
    guard let event = state.eventsState.getEventBy(id: eventId), let screen = state.eventsState.eventScreens[screenId] else { return nil }
    let token = state.authState.loginStatus.getUserCredentials()?.token
    
    self.event = event
    self.screenId = screenId
    self.comments = screen.comments
    self.replyedComments = screen.replyedComments
    
    if let distance = state.locationState.location?.distance(from: CLLocation(latitude: event.latitude, longitude: event.longitude)) {
      self.distance = String(format: "%.1f км.", arguments: [distance / 1000])
    } else {
      self.distance = "?.? км."
    }
    
    self.didTapLike = {
      store.dispatch { (state, store) -> Action? in
        var cancelTask: Cancel?
        if let cancelLikeRequest = state.apiRequestsState.eventsLikeRequests[eventId]?.like {
          cancelLikeRequest()
        } else {
          let index = state.eventsState.list!.events.index { $0.id == eventId }!
          let event = state.eventsState.list!.events[index]
          guard let token = token else { return SetLoginState(.none) }
          let likeRequest = LikeEventRequest(token: token, action: event.like ? .removeLike : .addLike , eventid: eventId)
          let (eventPromise, cancel) = EventsService.send(likeRequest)
          cancelTask = cancel
          eventPromise
            .then { store.dispatch(EventLikeSent(event: $0)) }
            .catch { _ in store.dispatch(EventLikeInvertAction(eventId: eventId, cancelTask: nil)) }
        }
        return EventLikeInvertAction(eventId: eventId, cancelTask: cancelTask)
      }
    }
    
    
    self.didTapDislike = {
      store.dispatch { (state, store) -> Action? in
        var cancelTask: Cancel?
        if let cancelDislikeRequest = state.apiRequestsState.eventsLikeRequests[eventId]?.dislike {
          cancelDislikeRequest()
        } else {
          let index = state.eventsState.list!.events.index { $0.id == eventId }!
          let event = state.eventsState.list!.events[index]
          guard let token = token else {  return SetLoginState(.none)  }
          let dislikeRequest = LikeEventRequest(token: token, action: event.dislike ? .removeDisLike : .addDisLike, eventid: eventId)
          let (eventPromise, cancel) = EventsService.send(dislikeRequest)
          cancelTask = cancel
          eventPromise
            .then {  store.dispatch( EventDislikeSent(event: $0) )}
            .catch { _ in store.dispatch(EventDislikeInvertAction(eventId: eventId, cancelTask: nil)) }
        }
        return EventDislikeInvertAction(eventId: eventId, cancelTask: cancelTask)
      }
    }
    
    
    self.getMapURL = { width, height in
      return URL(string: state.eventsState.settings.mapBaseURL + "size=\(width)x\(height)&center=\(event.latitude),\(event.longitude)&markers=\(event.latitude),\(event.longitude)")
    }
    

    switch screen.fetchCommentsRequest {
    case .none, .success:
      loadMoreButtonState =  screen.isEndReached ? .none : .showButton
    case .run:
      loadMoreButtonState = .showLoading
    case .error:
      loadMoreButtonState = .showButtonWithError
    }
    
    
    if case .run? = state.eventsState.eventScreens[screenId]?.sendCommentRequest {
      self.shouldDisplayHUD = true
    } else {
      self.shouldDisplayHUD = false
    }
    
    
    self.didTapLoadMore = {
      store.dispatch{ (state, store) -> Action? in
        
        guard state.eventsState.eventScreens[screenId]?.isEndReached != true,
          let event = state.eventsState.getEventBy(id: eventId)
          else { return nil }
        
        let pagelimit = state.eventsState.settings.commentPageLimit
        let offset = max(event.commentsCount - screen.comments.count - pagelimit, 0)
        let limit = offset > 0 ? pagelimit : event.commentsCount - screen.comments.count

        let commentsPageAction = GetCommentsPage(
          screenId: screenId,
          eventId: eventId,
          limit: limit,
          offset: offset,
          maxId: event.maxCommentId ?? 0)
        
        return commentsPageAction
      }
    }
    
    
    self.onDeinitScreen = {
      store.dispatch(RemoveCommentsScreen(screenId: $0))
    }
    
    
    self.getActionsForComment = { index in
      let comment = screen.comments[index]
      var actions: [CommentAction] = [comment.like ? .dislike : .like, .answer]
      if event.solutionCommentId == nil { actions.append(.resolve) }
      return actions
    }
    
    
    self.didTapCommentAction = { action, index in
      let comment = screen.comments[index]
      
      switch action {
        
      case .like, .dislike:
        store.dispatch { (state, store) -> Action? in
         
          let cancelTask: Cancel?
          
          if let cancelRequestFunction = state.apiRequestsState.commentsLikeRequests[comment.id] {
            cancelRequestFunction()
            cancelTask = nil
          } else {
            guard let token = token else { return SetLoginState(.none) }
            let likeRequest = LikeCommentRequest(token: token, action: comment.like ? .removeLikeComment : .addLikeComment, id: comment.id)
            let (likeCommentPromise, cancel) = EventsService.send(likeRequest)
            cancelTask = cancel
            likeCommentPromise
              .then {
                store.dispatch(CommentLikeSent(commentId: comment.id)) }
              .catch { _ in
                store.dispatch(CommentLikeInvertAction(eventId: eventId, commentId: comment.id, cancelTask: nil)) }
          }
          
          return CommentLikeInvertAction(eventId: eventId, commentId: comment.id, cancelTask: cancelTask)
        }

      case .answer:
        store.dispatch(SetCommentType(screenId: screenId, type: .answer(comment.id)))
        
      case .resolve:
        store.dispatch(SetCommentType(screenId: screenId, type: .resolve(comment.id)))
        
      }
    }
    
    
    self.didTapSendComment = { message in
      store.dispatch(SendComment(screenId: screenId, eventId: screen.eventId, localId: UUID().uuidString, message: message, type: screen.textInputMode))
    }

    
    self.shouldShowPostedComment = {
      if case .success = state.eventsState.eventScreens[screenId]!.sendCommentRequest {
        store.dispatch(NewCommentShown(screenId: screenId))
        return true
      }
      return false
    }
    
    
    self.didTapClearQoute = {
      store.dispatch(SetCommentType(screenId: screenId, type: .new))
    }
  }
}
