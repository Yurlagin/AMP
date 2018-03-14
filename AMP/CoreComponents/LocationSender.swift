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
  private let sendFcmToken: (_ fcmToken: String, _ token: String) -> (Promise<()>, Cancel)
  
  var sendFcmCancelFunction: Cancel?
  var sendingFcmToken: String?
  
  init (sendLocation: @escaping (CLLocation, _ token: String) -> (Promise<()>, Cancel),
        sendFcmToken: @escaping (_ fcmToken: String, _ token: String) -> (Promise<()>, Cancel)) {
    self.sendLocation = sendLocation
    self.sendFcmToken = sendFcmToken
    store.subscribe(self)
  }
  

  func newState(state: AppState) {
    
    store.dispatch { (appState, store) -> Action? in
      
      let state = appState.locationState
      
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
    
    guard let credentials = state.authState.loginStatus.getUserCredentials(),
      credentials.fcmTokenDelivered == false,
      let newFcmToken = credentials.fcmToken,
      let token = state.authState.loginStatus.getUserCredentials()?.token else { return }
    
    if newFcmToken != sendingFcmToken {
      sendFcmCancelFunction?()
    }
    
    let (sendingPromise, cancel) = sendFcmToken(newFcmToken, token)
    self.sendFcmCancelFunction = cancel
    self.sendingFcmToken = newFcmToken
    
    sendingPromise
      .always { [weak self] in
        self?.sendFcmCancelFunction = nil
        self?.sendingFcmToken = nil
      }
      .then { _ -> () in
        UserDefaults.standard.set(true, forKey: "fcmTokenDelivered")
        UserDefaults.standard.synchronize()
        store.dispatch(FcmTokenDelivered())
      }
  }
  

}
