
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
  private var sendingLocationCancelation: Cancel?
  
  init (sendLocation: @escaping (CLLocation, _ token: String) -> (Promise<()>, Cancel)) {
    self.sendLocation = sendLocation
  }

  func newState(state: LocationState) {
    store.dispatch { [weak self] (appState, store) -> Action? in
      guard let currentLocation = state.currentlocation,
        state.lastSentLocation == nil || state.lastSentLocation!.distance(from: currentLocation) > locationThreshold,
        let token = appState.authState.loginStatus.userCredentials?.token
        else {
          return nil
      }
      
      if case .sending = state.sendingStatus {
        self?.sendingLocationCancelation?()
        self?.sendingLocationCancelation = nil
      }
      
      guard let strongSelf = self else { return nil }
      let (sendLocationPromise, cancel) = strongSelf.sendLocation(currentLocation, token)
      self?.sendingLocationCancelation = cancel
      
      sendLocationPromise
        .then { _ -> Void in
          if let userId = appState.settingsState.userInfo?.userId {
            MetricaImpl.shared.logUpdateLocation(userId: userId)
          } else {
            assertionFailure("Must have userId on the main flow")
          }
          store.dispatch(SendingLocationResult.success(currentLocation))
        }.catch { _ in
          store.dispatch(SendingLocationResult.error)
      }
      return SendLocation()
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
