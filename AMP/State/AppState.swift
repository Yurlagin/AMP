//
//  AppState.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 20.01.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift

struct AppState: StateType {
  let authState: AuthState
  let eventListState: EventListState
}

func appReducer(action: Action, state: AppState?) -> AppState {
  return AppState(
    authState: authReducer(action: action, state: state?.authState),
    eventListState: eventListReducer(action: action, state: state?.eventListState)
  )
}
