//
//  EventListViewModel.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 04.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift
import CoreLocation
import PromiseKit

extension EventListTableViewController: StoreSubscriber {
  
  func newState(state: AppState) {
    viewModel = EventListViewModel(state: state)
  }
  
}

struct EventListViewModel {
  
  var events = [Event]()
  let spinner: SpinnerType
  
  let onRefreshTableView: (()->())?
  let willDisplayCellAtIndex: ((Int)->())?
  
  let didTapLike: ((_ eventId: Int)->())?
  let didTapDislike: ((_ eventId: Int)->())?

  
  enum SpinnerType {
    case none
    case top
    case bottom
  }
  
  
  init (state: AppState) {
   
    events = state.eventsState.list?.events ?? []
    spinner = state.eventsState.listRequest.getSpinnerType()
  
    let refresh = {
      store.dispatch({ (appState, store) -> Action? in
        guard let token = state.authState.loginStatus.getUserCredentials()?.token else { return nil } // TODO: изменить состоение на неавторизованное
        switch appState.eventsState.listRequest {
        case .request:
          return nil
        default: break
        }
        
        let settings = state.eventsState.settings
        var location: CLLocation?
        
        EventsService.makeEventListRequest(
          radius: settings.radius,
          limit: settings.pageLimit,
          offset: 0,
          maxId: 0,
          onlyActive: settings.onlyActive,
          onlyMine: settings.onlyMine,
          excludingIds: [],
          excludingTypes: settings.excludingTypes,
          token: token)
          .then { loc, request in
            location = loc
            return EventsService.getEventsList(request: request)
          }
          .then {
            store.dispatch(RefreshEventsList(location: location!, events: $0))
          }.catch {
            store.dispatch(SetEventListError($0))
        }
        return SetEventListRequestStatus(.request(.refresh))
      })
    }
    
    onRefreshTableView = refresh
    
    willDisplayCellAtIndex = { index in
      
      store.dispatch{ (appState, store) -> Action? in
        
        guard let events = appState.eventsState.list?.events,
          events.count - 1 - index <= appState.eventsState.settings.pageLimit / 2 ,
          !appState.eventsState.listRequest.isActive(),
          !appState.eventsState.isEndOfListReached else { return nil }
        
        guard let token = state.authState.loginStatus.getUserCredentials()?.token else { return SetLoginState(.none) }

        let settings = state.eventsState.settings
        
        EventsService.makeEventListRequest(
          location: appState.eventsState.list!.location,
          radius: settings.radius,
          limit: settings.pageLimit,
          offset: events.count,
          maxId: events.first?.id,
          onlyActive: settings.onlyActive,
          onlyMine: settings.onlyMine,
          excludingIds: [],
          excludingTypes: settings.excludingTypes,
          token: token)
          .then (on: DispatchQueue.global(qos: .userInitiated)){
            EventsService.getEventsList(request: $1)}
          .then {
            store.dispatch(AppendEventsToList($0))
          }.catch {
            store.dispatch(SetEventListError($0))
        }
        
        return SetEventListRequestStatus(.request(.loadMore))
      }
    }
    
    didTapLike = { eventId in
      store.dispatch { (state, store) -> Action? in
        var cancelTask: Cancel?
        if let cancelLikeRequest = state.apiRequestsState.eventsLikeRequests[eventId]?.like {
          cancelLikeRequest()
        } else {
          let index = state.eventsState.list!.events.index { $0.id == eventId }!
          let event = state.eventsState.list!.events[index]
          guard let token = state.authState.loginStatus.getUserCredentials()?.token else {  return SetLoginState(.none)  }
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
    
    didTapDislike = { eventId in
      store.dispatch { (state, store) -> Action? in
        var cancelTask: Cancel?
        if let cancelDislikeRequest = state.apiRequestsState.eventsLikeRequests[eventId]?.dislike {
          cancelDislikeRequest()
        } else {
          let index = state.eventsState.list!.events.index { $0.id == eventId }!
          let event = state.eventsState.list!.events[index]
          guard let token = state.authState.loginStatus.getUserCredentials()?.token else {  return SetLoginState(.none)  }
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
  }
}


extension EventsState.RequestStatus {
  
  func getSpinnerType() -> EventListViewModel.SpinnerType {
    if case .request(let type) = self {
      switch type {
      case .loadMore: return .bottom
      case .refresh: return .top
      }
    } else {
      return .none
    }
  }
  
  func isActive() -> Bool {
    if case .none = getSpinnerType() { return false }
    return true
  }
  
  func isRefreshing() -> Bool {
    if case .top = getSpinnerType() { return true }
    return false
  }
}
