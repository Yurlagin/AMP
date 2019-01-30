//
//  LocationReducer.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 11.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift

func locationReducer(action: Action, state: LocationState?) -> LocationState {
  var state = state ?? LocationState(currentlocation: nil, lastSentLocation: nil, sendingStatus: .none)
  
  switch action {
  case _ as ReSwiftInit:
    break
    
  case let action as SetNewLocation:
    state.currentlocation = action.location
    
  case is SendLocation:
    state.sendingStatus = .sending
    
  case let action as SendingLocationResult:
    switch action {
    case .success(let location):
      state.lastSentLocation = location
      state.sendingStatus = .none
    case .error:
      state.sendingStatus = .error
    }
    
  default:
    break
  }
  
  return state
}
