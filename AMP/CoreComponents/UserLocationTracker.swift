//
//  LocationTracker.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 11.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import CoreLocation
import ReSwift

class UserLocationTracker: CLLocationManager {
  
  override init() {
    super.init()
    distanceFilter = 200
    delegate = self
    subscribeToAppState()
  }
  
  private func subscribeToAppState() {
    let defaultCenter = NotificationCenter.default
    defaultCenter.addObserver(
      self,
      selector: #selector(startForegroundTracking),
      name: UIApplication.willEnterForegroundNotification,
      object: nil
    )
    defaultCenter.addObserver(
      self,
      selector: #selector(startBackgroundTracking),
      name: UIApplication.didEnterBackgroundNotification,
      object: nil
    )
  }
    
  private var isAuthorized: Bool {
    let status = CLLocationManager.authorizationStatus()
    switch status {
    case .authorizedWhenInUse, .authorizedAlways:
      return true
    case .denied, .restricted, .notDetermined:
      return false
    }
  }
  
  @objc func startForegroundTracking() {
    if isAuthorized {
      stopMonitoringSignificantLocationChanges()
      startUpdatingLocation()
    } else {
      requestAlwaysAuthorization()
    }
  }
  
  @objc private func startBackgroundTracking() {
    if case .authorizedAlways = CLLocationManager.authorizationStatus() {
      stopUpdatingLocation()
      startMonitoringSignificantLocationChanges()
    }
  }
  
   @objc private func startTracking() {
    let appState = UIApplication.shared.applicationState
    switch appState {
    case .active:
      startForegroundTracking()
    case .background:
      startForegroundTracking()
    case .inactive:
      break
    }
  }
  
}

extension UserLocationTracker: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    store.dispatch(SetNewLocation(location))
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .authorizedAlways, .authorizedWhenInUse:
      startTracking()
    default:
      break
    }
  }
  
}
