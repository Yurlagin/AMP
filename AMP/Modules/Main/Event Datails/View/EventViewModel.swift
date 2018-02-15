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
  let distance: String
  let getMapURL: (CGFloat, CGFloat) -> (URL?)
  let didTapLike: ()->()
  let didTapDislike: ()->()
  
  init? (eventId: Int, state: AppState) {
    
    guard let event = state.eventListState.getEventBy(id: eventId) else { return nil }
    
    self.event = event
    
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
          let index = state.eventListState.list!.events.index { $0.id == eventId }!
          let event = state.eventListState.list!.events[index]
          guard let token = state.authState.loginStatus.getUserCredentials()?.token else { return SetLoginState(.none) }
          let likeRequest = EventService.LikeRequest(token: token, action: event.like ? .removeLike : .addLike , eventid: eventId) 
          let (eventPromise, cancel) = EventService.send(likeRequest)
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
          let index = state.eventListState.list!.events.index { $0.id == eventId }!
          let event = state.eventListState.list!.events[index]
          guard let token = state.authState.loginStatus.getUserCredentials()?.token else {  return SetLoginState(.none)  }
          let dislikeRequest = EventService.LikeRequest(token: token, action: event.dislike ? .removeDisLike : .addDisLike, eventid: eventId)
          let (eventPromise, cancel) = EventService.send(dislikeRequest)
          cancelTask = cancel
          eventPromise
            .then {  store.dispatch( DislikeEventSent(event: $0) )}
            .catch { _ in store.dispatch(DislikeInvertAction(eventId: eventId, cancelTask: nil)) }
        }
        return DislikeInvertAction(eventId: eventId, cancelTask: cancelTask)
      }
    }
    
    self.getMapURL = { width, height in
      return URL(string: state.eventListState.settings.mapBaseURL + "size=\(width)x\(height)&center=\(event.latitude),\(event.longitude)&markers=\(event.latitude),\(event.longitude)")
    }
    
  }
}
