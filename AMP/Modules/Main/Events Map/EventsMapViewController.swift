//
//  EventsMapViewController.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 28.01.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import UIKit
import MapKit

class EventsMapViewController: UIViewController, EventMapView {
  
  @IBOutlet weak var zoomInButton: UIButton!
  @IBOutlet weak var zoomOutButton: UIButton!
  @IBOutlet weak var findMeButton: UIButton!
  
  @IBOutlet weak var mapView: MKMapView!
  
  @IBAction func zoomInPressed(_ sender: UIButton) {
    zoomMap(byFactor: 0.5)
  }
  
  @IBAction func zoomOutPressed(_ sender: UIButton) {
    zoomMap(byFactor: 2)
  }
  
  @IBAction func findMePressed(_ sender: UIButton) {
    mapView.showAnnotations([mapView.userLocation], animated: true)
  }
  
  private let tileSource = "http://a.tile.openstreetmap.org/{z}/{x}/{y}.png"
  var onSelectItem: ((EventId) -> ())?

  
  private func zoomMap(byFactor scaleFactor: Double) {
    var region = mapView.region
    var span = mapView.region.span
    span.latitudeDelta *= scaleFactor
    span.longitudeDelta *= scaleFactor
    region.span = span
    mapView.setRegion(region, animated: true)
  }
  
  
  private func setInitialState() {
    mapView.showsUserLocation = true
    mapView.delegate = self
    let overlay = MKTileOverlay(urlTemplate: tileSource)
    overlay.canReplaceMapContent = true
    overlay.maximumZ = 18
    mapView.add(overlay)
    
    [findMeButton, zoomInButton, zoomOutButton].forEach {
      $0?.layer.masksToBounds = true
      $0?.layer.borderColor = UIColor.darkGray.cgColor
      $0?.layer.borderWidth = 1
      $0?.layer.cornerRadius = $0!.frame.height / 2
    }
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setInitialState()
  }
  
}

extension EventsMapViewController: MKMapViewDelegate   {
  
}
