
//  LocationSender.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 13.03.2018.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift
import CoreLocation
import PromiseKit

fileprivate let locationThreshold = 200.0

class LocationSender: StoreSubscriber {
  private let sendLocation: (CLLocation, _ token: String) -> (Promise<()>, Cancel)
//  private let sendFcmToken: (_ fcmToken: String, _ token: String) -> (Promise<()>, Cancel)
  
//  private var sendFcmCancelFunction: Cancel?
//  private var sendingFcmToken: String?
  private var sendingLocationCancelation: Cancel?
  
  init (sendLocation: @escaping (CLLocation, _ token: String) -> (Promise<()>, Cancel)) {
    self.sendLocation = sendLocation
//    store.subscribe(self)
  }

  func newState(state: AppState) {
    store.dispatch { [weak self] (appState, store) -> Action? in
      let state = appState.locationState
      
      guard let currentLocation = state.currentlocation,
        let token = appState.authState.loginStatus.userCredentials?.token,
        state.lastSentLocation == nil || state.lastSentLocation!.distance(from: currentLocation) > locationThreshold
        else {
          return nil
      }
      
      if case .sending = state.sendLocationRequest {
        self?.sendingLocationCancelation?()
        self?.sendingLocationCancelation = nil
      }
      
      guard let strongSelf = self else { return nil }
      let (sendLocationPromise, cancel) = strongSelf.sendLocation(currentLocation, token)
      self?.sendingLocationCancelation = cancel
      
      sendLocationPromise
        .then {
          store.dispatch(SendingLocationStatus.success(currentLocation))
        }.catch {
          store.dispatch(SendingLocationStatus.error($0))
      }
      return SendingLocationStatus.sending
    }
    
//    guard let credentials = state.authState.loginStatus.userCredentials,
//      credentials.fcmTokenDelivered == false,
//      let newFcmToken = credentials.fcmToken,
//      let token = state.authState.loginStatus.userCredentials?.token else { return }
//
//    if newFcmToken != sendingFcmToken {
//      sendFcmCancelFunction?()
//    }
//
//    let (sendingPromise, cancel) = sendFcmToken(newFcmToken, token)
//    self.sendFcmCancelFunction = cancel
//    self.sendingFcmToken = newFcmToken
//
//    sendingPromise
//      .then { _ -> () in
//        UserDefaults.standard.set(true, forKey: "fcmTokenDelivered")
//        UserDefaults.standard.synchronize()
//        store.dispatch(FcmTokenDelivered())
//      }
//      .always { [weak self] in
//        self?.sendFcmCancelFunction = nil
//        self?.sendingFcmToken = nil
//    }
  }
}
