//
//  EventListActions.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 04.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift
import CoreLocation

struct AppendEventsToList: Action {
  let events: [Event]
  init (_ events: [Event]) {
    self.events = events
  }
}

struct RefreshEventsList: Action {
  let location: CLLocation
  let events: [Event]
}

struct SetEventListError: Action {
  let error: Error
  init (_ error: Error) {
    self.error = error
  }
}

struct SetEventListRequestStatus: Action {
  let status: EventListState.RequestStatus
  init (_ status: EventListState.RequestStatus) { self.status = status }
}

struct LikeInvertAction: Action {
  let eventId: Int
  let cancelTask: (()->())?
}

struct DislikeInvertAction: Action {
  let eventId: Int
}

struct UpdateEvent: Action {
  let event: Event
  init (_ event: Event) {self.event = event}
}