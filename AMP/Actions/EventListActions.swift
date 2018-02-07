//
//  EventListActions.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 04.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift

struct RequestEventList: Action { }

struct AppendEventsToList: Action {
  let events: [Event]
  init (_ events: [Event]) {
    self.events = events
  }
}

struct RefreshEventsList: Action {
  let events: [Event]
  init (_ events: [Event]) {
    self.events = events
  }
}

struct SetEventListError: Action {
  let error: Error
  init (_ error: Error) {
    self.error = error
  }
}

