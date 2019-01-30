//
//  LocationReducer.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 11.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift

func locationReducer(action: Action, state: LocationState?) -> LocationState {
  
  var state = state ?? LocationState(currentlocation: nil, lastSentLocation: nil, sendLocationRequest: .none)
  
  switch action {
    
  case _ as ReSwiftInit:
    break
    
    
  case let action as SetNewLocation:
    state.currentlocation = action.location
//    print ("new location: \(action.location)")
    
    
  case let action as SendingLocationStatus:
    switch action {
    case .success(let sentLocation):
      state.lastSentLocation = sentLocation
      state.sendLocationRequest = .none
//      print("§§§ sent location: \(sentLocation)")
    default:
      state.sendLocationRequest = action
    }
    
  default:
    break
    
  }
  
  return state
}
