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
import Kingfisher

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

  var onSelect: ((EventId) -> ())?
  
  private let tileSource = "http://a.tile.openstreetmap.org/{z}/{x}/{y}.png"
  private let preloadScaleFactor = 1.5 //насколько большую площадь, чем отображаемую на карте, запрашивать при загрузке новых пинов
  private var viewModelRendered = true
  private var annotations = [EventAnnotation]()
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
  }
  
  private func setInitialState() {
    mapView.showsUserLocation = true
    showUserLocation(animated: false)

    mapView.delegate = self
    mapView.setUserTrackingMode(.follow, animated: false)
    mapView.userTrackingMode = .follow
    let overlay = MKTileOverlay(urlTemplate: tileSource)
    overlay.canReplaceMapContent = false
    overlay.maximumZ = 18
    mapView.insert(overlay, at: 0)
    
    [findMeButton, zoomInButton, zoomOutButton].forEach {
      $0?.layer.masksToBounds = true
      $0?.layer.borderColor = UIColor.darkGray.cgColor
      $0?.layer.borderWidth = 1
      $0?.layer.cornerRadius = $0!.frame.height / 2
    }
  }
  
  private func renderUI() {
    let newAnnotations = viewModel.events.map{EventAnnotation($0)}
    let removes = annotations.filter{oldAnnotation in
      !newAnnotations.contains(where: { oldAnnotation.eventId == $0.eventId})
    }
    let inserts = newAnnotations.filter{newAnnotation in
      !annotations.contains(where: { newAnnotation.eventId == $0.eventId})
    }
    mapView.removeAnnotations(removes)
    mapView.addAnnotations(inserts)
    annotations = newAnnotations
  }
  
  @objc func onTapEvent(sender: UITapGestureRecognizer) {
    guard let annotation = (sender.view as? MKAnnotationView)?.annotation as? EventAnnotation else { return }
    onSelect?(annotation.eventId)
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
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    guard let tileOverlay = overlay as? MKTileOverlay else {
      let rendener = MKOverlayRenderer(overlay: overlay)
      return rendener
    }
    return MKTileOverlayRenderer(tileOverlay: tileOverlay)
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation.isKind(of: MKUserLocation.self) { return nil }
    guard let annotation = annotation as? EventAnnotation else { return nil }
    let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pinView") ?? MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pinView")
    pinView.annotation = annotation
    pinView.canShowCallout = true
    return pinView
  }
  
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapEvent(sender:)))
    view.addGestureRecognizer(tapGesture)
  }
  
  func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
    view.gestureRecognizers?.removeAll()
  }
}

extension EventsMapViewController: StoreSubscriber {
  func newState(state: AppState) {
    self.viewModel = EventsMapViewModel(from: state)
  }
}
