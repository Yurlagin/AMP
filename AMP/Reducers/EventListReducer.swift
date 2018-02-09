//
//  EventListReducer.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 04.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift

func eventListReducer(action: Action, state: EventListState?) -> EventListState {
  
  var state = state ?? EventListState(list: nil, isEndOfListReached: false, request: .none)

  
  switch action {
    
  case _ as ReSwiftInit:
    break
    
  case _ as RequestEventList:
    state.request = .request(.refresh)
    
  case let action as RefreshEventsList:
    state.list = (action.location, action.events)
    state.request = .none
    
  default :
    break
    
  }
  
  print ("§§§ action: \(action)")
  print ("§§§ new state: \(state)\n\n")
  
  return state
}
