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
  let createEventState: CreateEventState
  let locationState: LocationState
  let settingsState: SettingsState
}

func appReducer(action: Action, state: AppState?) -> AppState {
  print("~~~ Action: \(action)")
  let newState = AppState(
    authState: authReducer(action: action, state: state?.authState),
    eventsState: eventsReducer(action: action, state: state?.eventsState),
    createEventState: createEventReducer(action: action, state: state?.createEventState),
    locationState: locationReducer(action: action, state: state?.locationState),
    settingsState: settingsReducer(action: action, state: state?.settingsState)
  )

  return newState
}
