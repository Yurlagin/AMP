//
//  LocationTracker.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 11.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import CoreLocation
import ReSwift

class LocationTracker: CLLocationManager {
  
  override init() {
    super.init()
    distanceFilter = 100
    delegate = self
    
  }
  
  private func subscribeToAppState() {
    let defaultCenter = NotificationCenter.default
    defaultCenter.addObserver(self, selector: #selector(startForegroundTracking), name: .UIApplicationWillEnterForeground, object: nil)
    defaultCenter.addObserver(self, selector: #selector(startBackgroundTracking), name: .UIApplicationDidEnterBackground, object: nil)
  }

  private func checkPermissions() {
    if CLLocationManager.authorizationStatus() == .notDetermined {
      requestWhenInUseAuthorization()
    }
  }
  
  @objc func startForegroundTracking() {
    checkPermissions()
    stopMonitoringSignificantLocationChanges()
    startUpdatingLocation()
  }
  
  @objc func startBackgroundTracking() {
    checkPermissions()
    stopUpdatingLocation()
    startMonitoringSignificantLocationChanges()
  }
  
}

extension LocationTracker: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    store.dispatch(SetNewLocation(location))
  } 
  
}
