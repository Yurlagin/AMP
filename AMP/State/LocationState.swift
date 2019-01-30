//
//  LocationState.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 10.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift
import CoreLocation

struct LocationState: StateType {
  var currentlocation: CLLocation? = nil
  var lastSentLocation: CLLocation? = nil
  var sendLocationRequest: SendingLocationStatus = .none
}

enum SendingLocationStatus: Action {
  case none
  case sending
  case error(Error)
  case success(CLLocation)
}
