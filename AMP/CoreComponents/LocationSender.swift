
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
  private var sendingLocation: CLLocation?
  
  init (sendLocation: @escaping (CLLocation, _ token: String) -> (Promise<()>, Cancel)) {
    self.sendLocation = sendLocation
  }

  func newState(state: LocationState) {
    store.dispatch { [weak self] (appState, store) -> Action? in
      guard self?.sendingLocation != state.currentlocation else {
        print("same location")
        return nil }
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
      strongSelf.sendingLocationCancelation = cancel
      strongSelf.sendingLocation = currentLocation
      
      sendLocationPromise
        .always { [weak self] in
          self?.sendingLocation = nil
          self?.sendingLocationCancelation = nil
        }
        .then { _ -> Void in
          if let userId = appState.settingsState.userInfo?.userId {
            MetricaImpl.shared.logUpdateLocation(userId: userId)
          } else {
            assertionFailure("Must have userId on the main flow")
          }
          store.dispatch(SendingLocationResult.success(currentLocation))
        }
        .catch { _ in
          store.dispatch(SendingLocationResult.error)
      }
      return SendLocation()
    }
  }
}
