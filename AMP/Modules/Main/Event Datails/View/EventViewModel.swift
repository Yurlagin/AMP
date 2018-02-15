//
//  EventViewModel.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 15.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import CoreLocation

struct EventViewModel {
  let event: Event
  let distance: String
  
  init? (eventId: Int, state: AppState) {
    guard let event = state.eventListState.getEventBy(id: eventId) else { return nil }
    self.event = event
    if let distance = state.locationState.location?.distance(from: CLLocation(latitude: event.latitude, longitude: event.longitude)) {
      self.distance = String(format: "%.1f км.", arguments: [distance / 1000])
    } else {
      self.distance = "?.? км."
    }
  }
}
