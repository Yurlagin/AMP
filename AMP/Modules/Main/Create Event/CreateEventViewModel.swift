//
//  CreateEventViewModel.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 05.03.2018.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import CoreLocation

struct CreateEventViewModel {
  
  let cancelTapped: () -> ()
  
  let sendEvent: (_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees, Event.EventType, _ howLong: TimeInterval, String) -> ()
  
  let shouldCleanForm: Bool
  
  let showError: Error?
  
  let shouldShowHUD: Bool
  
  let onDisappear: () -> ()
  
  init(state: AppState) {
    
    if case .success = state.apiRequestsState.createEventStatus {
      shouldCleanForm = true
    } else {
      shouldCleanForm = false
    }
    
    if case .run(_) = state.apiRequestsState.createEventStatus {
      shouldShowHUD = true
    } else {
      shouldShowHUD = false
    }
    
    if case .error(let error) = state.apiRequestsState.createEventStatus {
      showError = error
    } else {
      showError = nil
    }

    cancelTapped = {
      store.dispatch { state, store in
        if case .run(let cancelFuncation) = state.apiRequestsState.createEventStatus  {
          cancelFuncation()
          return CreateEventStatus.none
        }
        return nil
      }
    }
    
    sendEvent = { lat, lon, type, howLong, message in
      store.dispatch { state, store in
        guard let token = state.authState.loginStatus.getUserCredentials()?.token else { return nil }
        let params = CreateEventRequest.CreateEventParams(howlong: howLong, lat: lat, lon: lon, message: message, type: type)
        let request = CreateEventRequest(event: params, token: token)
        let (eventPromise, cancelFunction) = EventsService.make(request)
        eventPromise
          .then {
            store.dispatch(CreateEventStatus.success($0))
          }.catch {
            store.dispatch(CreateEventStatus.error($0))
        }
        return CreateEventStatus.run(cancelFunction: cancelFunction)
      }
    }
    
    onDisappear = {
      store.dispatch { state, store in
        if case .success(_) = state.apiRequestsState.createEventStatus {
          return CreateEventStatus.none
        }
        return nil
      }
    }
    
  }
  
}
