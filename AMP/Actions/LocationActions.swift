//
//  LocationActions.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 11.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift
import CoreLocation

struct SetNewLocation: Action {
  let location: CLLocation
  init (_ location: CLLocation) { self.location = location }
}

struct UpdateLocationSent: Action {
  let sent: Date
  init (_ sent: Date) { self.sent = sent }
}
