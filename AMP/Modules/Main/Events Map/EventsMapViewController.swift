//
//  EventsMapViewController.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 28.01.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import UIKit
import MapKit
import ReSwift

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
    showUserLocation(animated: true)
  }
  
  private func showUserLocation(animated: Bool) {
    mapView.showAnnotations([mapView.userLocation], animated: animated)
  }
  
  private let tileSource = "http://a.tile.openstreetmap.org/{z}/{x}/{y}.png"
  private let preloadScaleFactor = 1.5 //насколько большую площадь, чем отображаемую на карте, запрашивать при загрузке новых пинов

  var onSelectItem: ((EventId) -> ())?
  
  var viewModelRendered = true
  
  var annotations = Set<EventAnnotation>()
  
  var viewModel: EventsMapViewModel! {
    didSet {
      viewModelRendered = false
      view.setNeedsLayout()
    }
  }
  
  private func zoomMap(byFactor scaleFactor: Double) {
    var region = mapView.region
    var span = mapView.region.span
    span.latitudeDelta *= scaleFactor
    span.longitudeDelta *= scaleFactor
    region.span = span
    mapView.setRegion(region, animated: true)
  }
  
  fileprivate func getVisibleMapAnnotations() {
//    print ("mapView.gethAnnotations")
    let deltaX = mapView.visibleMapRect.size.width * (preloadScaleFactor - 1)
    let deltaY = mapView.visibleMapRect.size.height * (preloadScaleFactor - 1)
    let maxPoint = MKMapPointMake(mapView.visibleMapRect.origin.x + mapView.visibleMapRect.size.width + deltaX,
                                  mapView.visibleMapRect.origin.y + mapView.visibleMapRect.size.height + deltaY)
    let minPoint = MKMapPointMake(mapView.visibleMapRect.origin.x - deltaX,
                                  mapView.visibleMapRect.origin.y - deltaY)
    let minLon = MKCoordinateForMapPoint(minPoint).longitude
    let minLat = MKCoordinateForMapPoint(maxPoint).latitude
    let maxLon = MKCoordinateForMapPoint(maxPoint).longitude
    let maxLat = MKCoordinateForMapPoint(minPoint).latitude
    viewModel?.fetchEventsFor(maxLat, maxLon, minLat, minLon)
//    annotationList.fetchAnnotations(maxLat: maxLat, minLat: minLat, maxLon: maxLon, minLon: minLon)
  }

  
  
  private func setInitialState() {
    mapView.showsUserLocation = true
    showUserLocation(animated: false)
//    mapView.

    mapView.delegate = self
    mapView.setUserTrackingMode(.follow, animated: false)
    mapView.userTrackingMode = .follow
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
  
  
  
  private func renderUI() {
    mapView.removeAnnotations(Array(annotations.subtracting(viewModel.events)))
    mapView.addAnnotations(Array(viewModel.events.subtracting(annotations)))
    self.annotations = viewModel.events
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setInitialState()
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    store.subscribe(self)
  }
  
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    store.unsubscribe(self)
  }
  
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    if !viewModelRendered {
      renderUI()
      viewModelRendered = true
    }
  }
}



extension EventsMapViewController: MKMapViewDelegate   {
  
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    if mapView.getZoomLevel() < 10 {
      mapView.setCenter(coordinate: mapView.centerCoordinate, zoomLevel: 10, animated: true)
    } else {
      getVisibleMapAnnotations()
    }
  }
  
  
  func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
  }
  
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    guard let tileOverlay = overlay as? MKTileOverlay else {
      let rendener = MKOverlayRenderer(overlay: overlay)
      return rendener
    }
    return MKTileOverlayRenderer(tileOverlay: tileOverlay)
  }
  
}

extension EventsMapViewController: StoreSubscriber {
  
  func newState(state: AppState) {
    self.viewModel = EventsMapViewModel(from: state)
  }
  
}


