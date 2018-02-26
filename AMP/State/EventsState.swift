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
  
  var list: (location: CLLocation, events: [Event])?
  var isEndOfListReached: Bool
  var settings: Settings
  var eventScreens: [ScreenId: EventScreen]
  var listRequest: RequestStatus
  
  
  enum RequestStatus {
    case none
    case request(RequestType)
    case error(Error)
    
    enum RequestType {
      case refresh
      case loadMore
    }
  }
  
  struct Settings {
    var radius = 20
    var excludingTypes: Set<Event.EventType> = []
    var onlyActive = false
    var onlyMine = false
    var pageLimit = 20
    var commentPageLimit = 10
    let mapBaseURL = "https://usefulness.club/amp/staticmap.php?zoom=15&"
  }
  
  struct EventScreen {
    var comments: [Comment]
    var eventId: Int
    var isEndReached: Bool
    var fetchCommentsRequest: Request
    var sendCommentRequest: Request
    var outgoingCommentId: String?
    var textInputMode: CommentType
    
    enum Request {
      case none
      case run
      case error(Error)
      case success
    }
  }
}

enum CommentType {
  case new
  case answer(CommentId)
  case resolve(CommentId)
}


extension EventsState {
  func getEventBy(id: Int) -> Event? {
    guard let index = list?.events.index(where: {$0.id == id }) else { return nil }
    return list?.events[index]
  }
}



