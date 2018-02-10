//
//  EventListReducer.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 04.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift

func eventListReducer(action: Action, state: EventListState?) -> EventListState {
  
  var newState = state ?? EventListState(list: nil, isEndOfListReached: false, settings: EventListState.Settings(), request: .none)

  switch action {
    
  case _ as ReSwiftInit:
    break
    
  case let action as SetEventListRequestStatus:
    newState.request = action.status
    
  case let action as RefreshEventsList:
    newState.list = (action.location, action.events)
    newState.request = .none
    
  case let action as AppendEventsToList:
    newState.list?.events.append(contentsOf: action.events)
    newState.request = .none

    
  default :
    break
    
  }
  
//  print ("§§§ action: \(action)")
//  print ("§§§ new state: \(state)\n\n")
  
  return newState
}
