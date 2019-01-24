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

extension EventListViewController {
  
  struct Props {
    let userLocation: CLLocation?
    var events = [Event]()
    let spinner: SpinnerType
    
    let onRefreshTableView: (() -> Void)
    let willDisplayCellAtIndex: ((Int) -> Void)
    
    let didTapLike: ((_ eventId: EventId) -> Void)?
    let didTapDislike: ((_ eventId: EventId) -> Void)?
    
    enum SpinnerType {
      case none
      case top
      case bottom
    }
    
    init (state: AppState, refreshEvents: @escaping (() -> Void), willDisplayCellAtIndex: @escaping (Int) -> Void) {
      self.userLocation = state.locationState.currentlocation
      self.events = (state.eventsState.eventListItems ?? []).map{$0.event}
      self.spinner = state.eventsState.getSpinnerType()
      self.onRefreshTableView = refreshEvents
      self.willDisplayCellAtIndex = willDisplayCellAtIndex
      self.didTapLike = { eventId in
        store.dispatch(EventLikeInvertAction(eventId: eventId))
      }
      self.didTapDislike = { eventId in
        store.dispatch(EventDislikeInvertAction(eventId: eventId))
      }
    }
  }
}

extension EventsState {
  var eventListItems: [EventState]? {
    guard let eventList = eventList else { return nil }
    return allEvents
      .compactMap{ (keyValue) in
        let (id, eventState) = keyValue
        return eventList.eventIds.contains(id) ? eventState : nil }
      .sorted(by: { $1.event.created < $0.event.created })
  }
  
  func getSpinnerType() -> EventListViewController.Props.SpinnerType {
    switch eventListStatus {
    case .loading:
      return .top
      
    case .done(let eventList):
      switch eventList.updatingStatus {
      case .loadMore:
        return .bottom
        
      case .refreshing:
        return .top
        
      default:
        return .none
      }
      
    default:
      return .none
    }
  }
  
  var isLoading: Bool {
    return getSpinnerType() != .none
  }
  
  var hasAllEventsForList: Bool {
    if case .done(let eventList) = self.eventListStatus {
      return !eventList.hasMore
    } else {
      return false
    }
  }
}
