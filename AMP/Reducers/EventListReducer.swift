//
//  EventListReducer.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 04.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift

func eventListReducer(action: Action, state: EventListState?) -> EventListState {
  
  var state = state ?? EventListState(location: nil, events: [], requestStatus: .none)

  
  switch action {
    
  case _ as ReSwiftInit:
    break
    
  case _ as RequestEventList:
    state.requestStatus = .request(.refresh)
    
  default :
    break
    
  }
  
  print ("§§§ action: \(action)")
  print ("§§§ new state: \(state)\n\n")
  
  return state
}
