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
  let status: EventsState.RequestStatus
  init (_ status: EventsState.RequestStatus) { self.status = status }
}

struct LikeInvertAction: Action {
  let eventId: Int
  let cancelTask: (()->())?
}

struct DislikeInvertAction: Action {
  let eventId: Int
  let cancelTask: (()->())?
}

struct LikeEventSent: Action {
  let event: Event
}

struct DislikeEventSent: Action {
  let event: Event
}

struct CreateCommentsScreen: Action {
  let screenId: ScreenId
  let eventId: EventId
}

struct RemoveCommentsScreen: Action {
  let screenId: ScreenId
}
