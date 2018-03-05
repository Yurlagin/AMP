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
        
    }
    
  }
  
}
