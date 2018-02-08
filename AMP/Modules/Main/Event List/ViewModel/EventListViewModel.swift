//
//  EventListViewModel.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 04.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift

extension EventListTableViewController: StoreSubscriber {
  
  func newState(state: EventListState) {
    viewModel = EventListViewModel(state: state)
  }
  
}

struct EventListViewModel {
  
  let events: [Event]
  let spinner: SpinnerType
  let onDidLoad: (()->())?
  
  enum SpinnerType {
    case none
    case top
    case bottom
  }
  
  init (state: EventListState) {
   
    self.events = state.list?.events ?? []
  
    spinner = state.request.getSpinnerType()
    
    onDidLoad = {
      
      let filter = EventService.EventListRequest.Filter(exclude: [], helps: true, founds: true, chats: true, witness: true, gibdds: true, alerts: true, news: true, questions: true, onlyactive: true, lat: 0, lon: 0)
      
      store.dispatch({ (state, store) -> Action? in
        guard case .loggedIn(let user, let logout) = state.authState.loginStatus, case .none = logout else { return nil }
        let events = state.eventListState.list?.events
        let maxId = events?.first?.id
        let offset = events?.count
        EventService.getEventsList(parameters: EventService.EventListRequest(filter: filter, token: user.token, maxId: maxId, limit: 20, offset: offset ?? 0))
          .then {
            store.dispatch(RefreshEventsList(location: $0.0, events: $0.1))
          }.catch {
            store.dispatch(SetEventListError($0))
        }
        return RequestEventList()
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
}
