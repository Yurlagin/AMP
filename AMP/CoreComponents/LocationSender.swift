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

class LocationSender: StoreSubscriber {
  
  private let sendLocation: (CLLocation, _ token: String) -> (Promise<()>, Cancel)

  
  init (sendLocation: @escaping (CLLocation, _ token: String) -> (Promise<()>, Cancel)) {
    self.sendLocation = sendLocation
    store.subscribe(self)
  }
  

  func newState(state: AppState) {
    
    let state = state.locationState
    
    store.dispatch { (appState, store) -> Action? in

      guard let currentLocation = state.currentlocation,
        let token = appState.authState.loginStatus.getUserCredentials()?.token,
        state.lastSentLocation == nil || state.lastSentLocation!.distance(from: currentLocation) > 200 else { return nil }
      
      if case .run = state.sendLocationRequest { return nil }
      
      let (sendLocationPromise, cancel) = self.sendLocation(currentLocation, token)
      
      sendLocationPromise
        .then {
          store.dispatch(SendLocationRequest.success(currentLocation))
        }.catch {
          store.dispatch(SendLocationRequest.error($0))
      }
      
      return SendLocationRequest.run(cancel)
    }
    
  }
  

}
