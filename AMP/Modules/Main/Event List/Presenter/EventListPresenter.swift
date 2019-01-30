//
//  EventListPresenter.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 08/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import ReSwift
import CoreLocation

protocol EventListViewInput: class {
  func renderProps(_ props: EventListViewController.Props)
}

protocol EventListViewOutput {
  func onViewDidLoad() -> Void
  func onViewWillAppear() -> Void
  func onViewDidDissapear() -> Void
}

class EventListPresenter {
  private weak var view: EventListViewInput?
  private var cancelNetworkTask: Cancel?
  
  init(view: EventListViewInput) {
    self.view = view
  }
  
  deinit {
    cancelNetworkTask?()
  }
  
  private lazy var refreshEvents: () -> Void = { [weak self] in
    store.dispatch { (state, store) -> Action? in
      guard let token = state.authState.loginStatus.userCredentials?.token else {
        return nil
      }
      
      if state.eventsState.isLoading {
        self?.cancelNetworkTask?()
        self?.cancelNetworkTask = nil
      }
      
      let settings = state.eventsState.settings
      var location: CLLocation?
      
      ApiServiceImpl()
        .makeEventListRequest (
          radius: settings.radius,
          limit: settings.pageLimit,
          offset: 0,
          maxId: 0,
          onlyActive: settings.onlyActive,
          onlyMine: settings.onlyMine,
          excludingIds: [],
          excludingTypes: settings.excludingTypes,
          token: token
        )
        .then { loc, request in
          location = loc
          return ApiServiceImpl().getEvents(request: request)
        }
        .then { events in
          store.dispatch(RefreshEventsList(location: location!, events: events))
        }.catch {
          store.dispatch(SetEventListError($0))
      }
      
      return LoadEventList()
    }
  }
  
  private lazy var willDisplayCellAtIndex: (Int) -> Void = { index in
    store.dispatch{ (state, store) -> Action? in
      guard let events = state.eventsState.eventListItems else { return nil }
      guard
        (events.count - 1) - index <= 1,
        !state.eventsState.isLoading,
        !state.eventsState.hasAllEventsForList else { return nil }
      guard let token = state.authState.loginStatus.userCredentials?.token else {
        return SetLoginState(.none)
      }
      
      guard var eventList = state.eventsState.eventList else {
        assertionFailure("We should not be here")
        return nil
      }
      
      let settings = state.eventsState.settings
      
      ApiServiceImpl().makeEventListRequest(
        location: eventList.location,
        radius: settings.radius,
        limit: settings.pageLimit,
        offset: events.count,
        maxId: events.first?.event.id,
        onlyActive: settings.onlyActive,
        onlyMine: settings.onlyMine,
        excludingIds: [],
        excludingTypes: settings.excludingTypes,
        token: token)
        .then (on: DispatchQueue.global(qos: .userInitiated)){
          ApiServiceImpl().getEvents(request: $1)}
        .then {
          store.dispatch(AppendEventsToList($0))
        }.catch {
          store.dispatch(SetEventListError($0))
      }
      return LoadMoreEvents()
    }
  }
}

extension EventListPresenter: EventListViewOutput {
  
  func onViewDidLoad() {
    refreshEvents()
  }
  
  func onViewWillAppear() {
    store.subscribe(self)
  }
  
  func onViewDidDissapear() {
    store.unsubscribe(self)
  }
}

extension EventListPresenter: StoreSubscriber {
  
  func newState(state: AppState) {
    view?.renderProps(
      EventListViewController.Props(
        state: state,
        refreshEvents: refreshEvents,
        willDisplayCellAtIndex: willDisplayCellAtIndex
      )
    )
  }
  
}
