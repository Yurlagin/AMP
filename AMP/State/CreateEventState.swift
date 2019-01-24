//
//  CreateEventState.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 23/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import Foundation

struct CreateEventState: Hashable {
  var creationState: FormState
  var draft: EventDraft
  
  enum FormState: Hashable {
    case clean
    case draft
    case sending
    case error(errorTitle: String, errorText: String)
    case done(eventId: EventId)
  }
  
  struct EventDraft: Hashable {
    var long: Double
    var lat: Double
    var type: Event.EventType
    var howLong: TimeInterval
    var message: String
    
    static func createEmptyDraft() -> EventDraft {
      return EventDraft(long: 0, lat: 0, type: Event.EventType.alerts, howLong: 3600, message: "")
    }
  }
}
