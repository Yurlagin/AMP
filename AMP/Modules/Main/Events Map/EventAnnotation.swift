//
//  EventAnnotation.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 04.03.2018.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import MapKit

class EventAnnotation: NSObject, MKAnnotation {
  
  var coordinate: CLLocationCoordinate2D
  var title: String?
  var subtitle: String?
  var avatarUrl: String?
  
  
  init(_ event: Event) {
    self.coordinate = CLLocationCoordinate2DMake(event.latitude, event.longitude)
    self.title = event.userName ?? "Без имени"
    self.subtitle = event.message
    self.avatarUrl = event.avatarUrl
  }
  
  
}
