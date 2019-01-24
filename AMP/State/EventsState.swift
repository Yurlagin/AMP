//
//  EventListState.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 04.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift
import CoreLocation

struct EventsState: StateType {
  
  var allEvents: [EventId: EventState]
  var eventListStatus: EventListStatus
  var settings: Settings
  
  enum EventListStatus {
    case none
    case loading
    case done(EventList)
    case error(Error)
  }
  
  struct EventList {
    var location: CLLocation
    var eventIds: Set<EventId>
    var hasMore: Bool
    var updatingStatus: UpdatingStatus
    
    enum UpdatingStatus {
      case none
      case refreshing
      case loadMore
      case error(Error)
    }
  }
  
  struct Settings {
    var radius = 3
    var excludingTypes: Set<Event.EventType> = []
    var onlyActive = false
    var onlyMine = false
    var pageLimit = 20
    var commentPageLimit = 5
  }
}

enum CommentType: Hashable {
  case new
  case answer(CommentId)
  case resolve(CommentId)
}

extension EventsState {
  func getEventBy(id: EventId) -> Event? {
    return allEvents[id]?.event
  }
}

struct EventState: Hashable {
  var event: Event
  var commentDraft: CommentDraft
  var loadCommentsStatus: LoadState = .none
  
  struct CommentDraft: Hashable {
    var type: CommentType
    var text: String
    var postingState: LoadState
  }
  
}

extension EventState {
  init(event: Event) {
    self.event = event
    self.commentDraft = CommentDraft(type: .new, text: "", postingState: .none)
  }
}

enum LoadState: Hashable {
  case none
  case loading
  case error
}
