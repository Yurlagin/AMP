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
  
  var location: CLLocation?
  var sent: Date?
  
}

