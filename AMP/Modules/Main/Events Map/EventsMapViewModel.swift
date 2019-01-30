//
//  EventsMapViewModel.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 03.03.2018.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import Foundation

struct EventsMapViewModel {
  let events: [Event]
  let fetchEventsFor: (_ maxLat: Double, _ maxLon: Double, _ minLat: Double, _ minLon: Double) -> ()
  static let filterInterval: TimeInterval = 3 * 60 * 60
  
  init (from state: AppState ) {
    let events = state.eventsState.allEvents.values
      .map{$0.event}
      .filter{-$0.created.timeIntervalSinceNow < EventsMapViewModel.filterInterval}
    self.events = events
    self.fetchEventsFor = { maxLat, maxLon, minLat, minLon in
      store.dispatch(DidChangeMapRect(
        maxLat: maxLat,
        maxLon: maxLon,
        minLat: minLat,
        minLon: minLon,
        excludeEventIds: Set(events.map{$0.id}))
      )
    }
  }
}
