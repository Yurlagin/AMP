//
//  LocationService.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 13.03.2018.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import Alamofire
import PromiseKit


enum LocationService {
  
  static func sendLocation (_ location: CLLocation) -> Promise<()> {
    return Promise()
  }
  
}
