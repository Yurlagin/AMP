//
//  CreateEventViewModel.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 05.03.2018.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import CoreLocation

struct CreateEventViewModel {
  
  let sendEvent: (_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees, Event.EventType, _ howLong: TimeInterval, String) -> ()
  
  init() {
    
    sendEvent = { lat, lon, type, howLong, message in
      
      store.dispatch { state, store in
        guard let token = state.authState.loginStatus.getUserCredentials()?.token else { return nil }
        let params = CreateEventRequest.CreateEventParams(howlong: howLong, lat: lat, lon: lon, message: message, type: type)
        let request = CreateEventRequest(params: params, token: token)
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
    
  }
  
}
