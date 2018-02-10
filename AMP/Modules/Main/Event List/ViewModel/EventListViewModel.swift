//
//  EventListViewModel.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 04.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift
import CoreLocation

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
  
  enum SpinnerType {
    case none
    case top
    case bottom
  }
  
  
  init (state: AppState) {
   
    events = state.eventListState.list?.events ?? []
    spinner = state.eventListState.request.getSpinnerType()
  
    let refresh = {
      store.dispatch({ (appState, store) -> Action? in
        guard let token = state.authState.loginStatus.getUserCredentials()?.token else { return nil } // TODO: изменить состоение на неавторизованное
        switch appState.eventListState.request {
        case .request:
          return nil
        default: break
        }
        
        let settings = state.eventListState.settings
        var location: CLLocation?
        
        EventService.makeEventListRequest(
          radius: settings.radius,
          limit: settings.pageLimit,
          offset: 0,
          maxId: 0,
          onlyActive: settings.onlyActive,
          onlyMine: settings.onlyMine,
          excludingIds: [],
          excludingTypes: settings.excludeIds,
          token: token)
          .then { loc, request in
            location = loc
            return EventService.getEventsList(request: request)
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
      
      store.dispatch({ (appState, store) -> Action? in
        guard let events = appState.eventListState.list?.events, index == events.count - 1 else { return nil }
        guard let location = appState.eventListState.list?.location else { return nil }
       
        switch appState.eventListState.request {
        case .request:
          return nil
        default: break
        }
        
        guard let token = state.authState.loginStatus.getUserCredentials()?.token else { return SetLoginState(.none) }  // TODO: изменить состоение на неавторизованное
        let settings = state.eventListState.settings
        
        EventService.makeEventListRequest(
          location: location,
          radius: settings.radius,
          limit: settings.pageLimit,
          offset: events.count,
          maxId: events.first?.id,
          onlyActive: settings.onlyActive,
          onlyMine: settings.onlyMine,
          excludingIds: [],
          excludingTypes: settings.excludeIds,
          token: token)
          .then (on: DispatchQueue.global(qos: .userInitiated)){
            EventService.getEventsList(request: $1)}
          .then {
            store.dispatch(AppendEventsToList($0))
          }.catch {
            store.dispatch(SetEventListError($0))
        }
        return SetEventListRequestStatus(.request(.loadMore))
      })
    }
    
  }
}


extension EventListState.RequestStatus {
  
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
  
  func isRefreshing() -> Bool {
    if case .top = getSpinnerType() { return true }
    return false
  }
}
