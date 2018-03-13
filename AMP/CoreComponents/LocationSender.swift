//
//  LocationSender.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 13.03.2018.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift
import CoreLocation
import PromiseKit

class LocationSender {
  
  private let sendLocation: (CLLocation) -> Promise<()>

  init (sendLocation: @escaping (CLLocation) -> Promise<()>) {
    self.sendLocation = sendLocation
  }
    
}

extension LocationSender: StoreSubscriber {
  
  func newState(state: LocationState) {
    store.dispatch { (state, store) -> Action? in
      
      return nil
    }
  }

}
