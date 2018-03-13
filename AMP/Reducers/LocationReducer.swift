//
//  LocationReducer.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 11.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift

func locationReducer(action: Action, state: LocationState?) -> LocationState {
  
  var state = state ?? LocationState(location: nil, lastSent: nil)
  
  switch action {
    
  case _ as ReSwiftInit:
    break
    
  case let action as SetNewLocation:
    state.location = action.location
    print ("new location: \(action.location)")
    
  default:
    break
    
  }
  
  return state
}
