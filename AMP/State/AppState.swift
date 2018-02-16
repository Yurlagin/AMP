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
  let eventsState: EventsState
  let locationState: LocationState
  let apiRequestsState: ApiRequestsState
}

func appReducer(action: Action, state: AppState?) -> AppState {
  return AppState(
    authState: authReducer(action: action, state: state?.authState),
    eventsState: eventsReducer(action: action, state: state?.eventsState),
    locationState: locationReducer(action: action, state: state?.locationState),
    apiRequestsState: apiRequestsReducer(action: action, state: state?.apiRequestsState)
  )
}
