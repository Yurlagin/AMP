//
//  ApiRequestsReducer.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 12.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift

func apiRequestsReducer(action: Action, state: ApiRequestsState?) -> ApiRequestsState {
  
  var state = state ?? ApiRequestsState(likeRequests: [:])
  
  switch action {
    
  case _ as ReSwiftInit:
    break
    
    
  default :
    break
    
  }
  
  return state
}

