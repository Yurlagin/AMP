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
  let loadMoreButtonState: LoadMoreState
  let onDeinitScreen: (ScreenId) -> ()
  let distance: String
  let getMapURL: (CGFloat, CGFloat) -> (URL?)
  let didTapLike: () -> ()
  let didTapDislike: () -> ()
  let didTapLoadMore: () -> ()
  let getActionsForComment: (_ commentIndex: Int) -> (Set<CommentAction>)
  let didTapCommentAction: (CommentAction, _ commentIndex: Int) -> ()
  
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
    
    guard let event = state.eventsState.getEventBy(id: eventId), let screen = state.eventsState.commentScreens[screenId] else { return nil }
    
    self.event = event
    self.screenId = screenId
    self.comments = screen.comments

    
    if let distance = state.locationState.location?.distance(from: CLLocation(latitude: event.latitude, longitude: event.longitude)) {
      self.distance = String(format: "%.1f км.", arguments: [distance / 1000])
    } else {
      self.distance = "?.? км."
    }
    
    self.didTapLike = {
      store.dispatch { (state, store) -> Action? in
        var cancelTask: Cancel?
        if let cancelLikeRequest = state.apiRequestsState.likeRequests[eventId]?.like {
          cancelLikeRequest()
        } else {
          let index = state.eventsState.list!.events.index { $0.id == eventId }!
          let event = state.eventsState.list!.events[index]
          guard let token = state.authState.loginStatus.getUserCredentials()?.token else { return SetLoginState(.none) }
          let likeRequest = LikeEventRequest(token: token, action: event.like ? .removeLike : .addLike , eventid: eventId)
          let (eventPromise, cancel) = EventsService.send(likeRequest)
          cancelTask = cancel
          eventPromise
            .then { store.dispatch(LikeEventSent(event: $0)) }
            .catch { _ in store.dispatch(LikeInvertAction(eventId: eventId, cancelTask: nil)) }
        }
        return LikeInvertAction(eventId: eventId, cancelTask: cancelTask)
      }
    }
    
    
    self.didTapDislike = {
      store.dispatch { (state, store) -> Action? in
        var cancelTask: Cancel?
        if let cancelDislikeRequest = state.apiRequestsState.likeRequests[eventId]?.dislike {
          cancelDislikeRequest()
        } else {
          let index = state.eventsState.list!.events.index { $0.id == eventId }!
          let event = state.eventsState.list!.events[index]
          guard let token = state.authState.loginStatus.getUserCredentials()?.token else {  return SetLoginState(.none)  }
          let dislikeRequest = LikeEventRequest(token: token, action: event.dislike ? .removeDisLike : .addDisLike, eventid: eventId)
          let (eventPromise, cancel) = EventsService.send(dislikeRequest)
          cancelTask = cancel
          eventPromise
            .then {  store.dispatch( DislikeEventSent(event: $0) )}
            .catch { _ in store.dispatch(DislikeInvertAction(eventId: eventId, cancelTask: nil)) }
        }
        return DislikeInvertAction(eventId: eventId, cancelTask: cancelTask)
      }
    }
    
    
    
    self.getMapURL = { width, height in
      return URL(string: state.eventsState.settings.mapBaseURL + "size=\(width)x\(height)&center=\(event.latitude),\(event.longitude)&markers=\(event.latitude),\(event.longitude)")
    }
    

    switch screen.request {
    case .none:
      loadMoreButtonState =  screen.isEndReached ? .none : .showButton
    case .run:
      loadMoreButtonState = .showLoading
    case .error:
      loadMoreButtonState = .showButtonWithError
    }
    
    
    
    self.didTapLoadMore = {
      store.dispatch{ (state, store) -> Action? in
        
        guard state.eventsState.commentScreens[screenId]?.isEndReached != true,
          let event = state.eventsState.getEventBy(id: eventId)
          else { return nil }
        print ("passed")
        
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
      var actions: Set<CommentAction> = [comment.like ? .dislike : .like, .answer]
      if event.solutionCommentId == nil { actions.insert(.resolve) }
      return actions
    }
    
    
    self.didTapCommentAction = { action, index in
      
      switch action {
      case .like, .dislike:
        break
      case .resolve:
        break
      default:
        break
      }
    }

  }
}
