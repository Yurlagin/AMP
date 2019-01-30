//
//  CreateEventViewController.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 28.01.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import UIKit
import MapKit
import MBProgressHUD
import ReSwift

class CreateEventViewController: KeyboardAdjustableViewController, CreateEventView {
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var eventTypePicker: UIPickerView!
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var pinHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var zoomInButton: UIButton!
  @IBOutlet weak var zoomOutButton: UIButton!
  @IBOutlet weak var findMeButton: UIButton!
  @IBOutlet weak var pinShadowView: UIView!
  @IBOutlet weak var placeHolderLabel: UILabel!
  
  @IBAction func zoomInPressed(_ sender: UIButton) {
    zoomMap(byFactor: 0.5)
  }
  @IBAction func zoomOutPressed(_ sender: UIButton) {
    zoomMap(byFactor: 2)
  }
  @IBAction func findMePressed(_ sender: UIButton) {
    mapView.setCenter(mapView.userLocation.coordinate, animated: true)
  }
  
  typealias Props = CreateEventState

  var onCreateEvent: ((EventId) -> ())?
  var onCancel: (() -> ())?
  
  var props: Props? {
    didSet {
      renderUI()
    }
  }
  private let tileSource = "http://a.tile.openstreetmap.org/{z}/{x}/{y}.png"
  private let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
  private let allValues = Event.EventType.allValues
  private var hud: MBProgressHUD?

  @objc private func cancel() {
    props?.onCancel()
    onCancel?()
  }
  
  @objc private func donePressed() {
    props?.onSend()
  }
  
  private func showUserLocation(animated: Bool) {
    mapView.showAnnotations([mapView.userLocation], animated: animated)
  }
  
  private func setup() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .cancel,
      target: self,
      action: #selector(cancel)
    )
    navigationItem.rightBarButtonItem = doneButton
   
    textView.text = ""
    eventTypePicker.selectRow(0, inComponent: 0, animated: false)
    textViewDidChange(textView)
    
    pinShadowView.layer.cornerRadius = pinShadowView.frame.height / 2
 
    textView.layer.borderWidth = 0.5
    textView.layer.borderColor = UIColor.darkGray.cgColor
    textView.layer.cornerRadius = 4
    
    [findMeButton, zoomInButton, zoomOutButton].forEach {
      $0?.layer.masksToBounds = true
      $0?.layer.borderColor = UIColor.darkGray.cgColor
      $0?.layer.borderWidth = 1
      $0?.layer.cornerRadius = $0!.frame.height / 2
    }

    eventTypePicker.dataSource = self
    eventTypePicker.delegate = self

    mapView.delegate = self
    mapView.showsUserLocation = true
    showUserLocation(animated: false)
    mapView.userTrackingMode = .follow
    let overlay = MKTileOverlay(urlTemplate: tileSource)
    overlay.canReplaceMapContent = true
    overlay.maximumZ = 18
    mapView.add(overlay)
    textView.delegate = self
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelEditing)))
  }
  
  private func catchUpPin(_ catchUp: Bool) {
    pinHeightConstraint.constant = catchUp ? 20 : 8
    UIView.animate(withDuration: 0.25) {
      self.view.layoutIfNeeded()
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
  
  private func renderUI() {
    guard let props = props else { return }
    doneButton.isEnabled = props.isEnabledDoneButton
    let draft = props.draft
    textView.text = draft.message
    let selectedPickerIndex = Event.EventType.allValues.map{$0.0}.firstIndex(of: draft.type) ?? 0
    eventTypePicker.selectRow(selectedPickerIndex, inComponent: 0, animated: false)
    setHud(visible: props.showHud)
    if let (title, text, completion) = props.errorAlert {
      showOkAlert(title: title, message: text, okCompletion: completion)
    }
    if case .done(let eventId) = props.creationState {
      view.endEditing(true)
      onCreateEvent?(eventId)
      props.onShowPostedEvent()
    }
  }
  
  private func setHud(visible: Bool) {
    if visible {
      if hud == nil {
        hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.removeFromSuperViewOnHide = true
      }
    } else {
      hud?.hide(animated: true)
      hud = nil
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    store.subscribe(self)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    store.unsubscribe(self)
  }
  
  @objc private func cancelEditing() {
    view.endEditing(true)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    view.endEditing(true)
  }
  
  override func adjustForKeyboard(params: KeyboardAdjustableViewController.KeyboardParameters) {
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, params.isShowing ? params.finalFrame.height : 0, 0)
    UIView.animate(withDuration: params.animationDuration) {
      self.view.layoutIfNeeded()
    }
  }
}

extension CreateEventViewController: UIPickerViewDataSource, UIPickerViewDelegate {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return allValues.count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return allValues[row].1
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    props?.onChangeEvent(type: allValues[row].0)
  }
}

extension CreateEventViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    if !animated{
      catchUpPin(true)
    }
  }
  
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    if !animated{
      let mapCenter = mapView.centerCoordinate
      props?.onChangeEvent(latitude: mapCenter.latitude, longitude: mapCenter.longitude)
      catchUpPin(false)
    }
  }
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    guard let tileOverlay = overlay as? MKTileOverlay else {
      let rendener = MKOverlayRenderer(overlay: overlay)
      return rendener
    }
    return MKTileOverlayRenderer(tileOverlay: tileOverlay)
  }
}

extension CreateEventViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    placeHolderLabel.isHidden = !textView.text.isEmpty
    props?.onDraft(text: textView.text)
  }
}
