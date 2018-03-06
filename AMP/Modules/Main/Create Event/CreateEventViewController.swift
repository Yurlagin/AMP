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

class CreateEventViewController: UIViewController, CreateEventView {
  
  var onCreateEvent: ((EventId) -> ())?
  
  var onCancel: (() -> ())?
  
  var viewModelRendered = true
  private var viewModel: CreateEventViewModel! {
    didSet {
      viewModelRendered = false
      view.setNeedsLayout()
    }
  }
  
  private let tileSource = "http://a.tile.openstreetmap.org/{z}/{x}/{y}.png"
  
  private let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
  
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
  
  
  @objc private func cancel() {
    viewModel?.cancelTapped()
    setInitialState()
    onCancel?()
  }
  
  
  @objc private func donePressed() {
    let coordinate = mapView.centerCoordinate
    viewModel.sendEvent(coordinate.latitude, coordinate.longitude, allValues[eventTypePicker.selectedRow(inComponent: 0)].0, 14400, textView.text)
  }
  
  
  private func showUserLocation(animated: Bool) {
    mapView.showAnnotations([mapView.userLocation], animated: animated)
  }
  
  
  private func setInitialState() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
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
    
    
  }
  
  
  @objc private func endEditing() {
    view.endEditing(true)
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
  
  
  var hud: MBProgressHUD?
  
  private func renderUI() {
    guard let viewModel = viewModel else { return }
    
    if viewModel.shouldShowHUD, hud == nil {
      hud = MBProgressHUD.showAdded(to: view, animated: true)
      hud?.removeFromSuperViewOnHide = true
      doneButton.isEnabled = false
    } else {
      doneButton.isEnabled = true
      hud?.hide(animated: true)
      hud = nil
    }
    
    
    if let error = viewModel.showError {
      showAlert(title: "Ошибка", message: error.localizedDescription)
    }
    
    if viewModel.shouldCleanForm {
      setInitialState()
    }
    
  }

  
  @objc private func adjustForKeyboard(notification: Notification) {
    let userInfo = notification.userInfo!
    let kbDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
    let finalKBFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    let isShowing = notification.name == Notification.Name.UIKeyboardWillShow
    
    UIView.animate(withDuration: kbDuration) {
      self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, isShowing ? finalKBFrame.height : 0, 0)
      self.view.layoutIfNeeded()
    }
  }

  
  override func viewDidLoad() {
    super.viewDidLoad()

    let cancelEditGesture = UITapGestureRecognizer(target: self, action: #selector(endEditing))
    scrollView.addGestureRecognizer(cancelEditGesture)
    
    NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: .UIKeyboardWillHide, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: .UIKeyboardWillShow, object: nil)

    setInitialState()
  }
  
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    if !viewModelRendered {
      renderUI()
      viewModelRendered = true
    }
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    store.subscribe(self)
  }
  
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    viewModel.onDisappear()
    store.unsubscribe(self)
  }
  
  let allValues = Event.EventType.allValues

}


extension CreateEventViewController: StoreSubscriber {
  
  func newState(state: AppState) {
    self.viewModel = CreateEventViewModel(state: state)
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
  
}


extension CreateEventViewController: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    if !animated{
      catchUpPin(true)
    }
  }
  
  
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    if !animated{
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
    doneButton.isEnabled = !textView.text.isEmpty
  }
  
}


extension UIViewController {
  
  func showAlert(title: String?, message: String?, completion: (()->())? = nil) {
    let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in
      completion?()
    }
    alertVC.addAction(okAction)
    present(alertVC, animated: true)
  }
  
}
