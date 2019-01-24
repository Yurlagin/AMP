//
//  CreateEventActions.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 24/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import ReSwift

// MARK: Create Event Actions

struct ChangeCreatingEventText: Action {
  let text: String
}

struct ChangeCreatingEventType: Action {
  let type: Event.EventType
}

struct ChangeCreatingEventCoordinates: Action {
  let latitude: Double
  let longitude: Double
}

struct PostEvent: Action {}

struct CancelPostingEvent: Action {}

enum EventPostingResult: Action {
  case done(newEvent: Event)
  case error(Error)
}

struct DidShowEventPostingError: Action {}

struct DidShowPostedEvent: Action {}
