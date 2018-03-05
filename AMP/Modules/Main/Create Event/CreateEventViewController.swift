//
//  CreateEventViewController.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 28.01.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import UIKit
import MapKit

class CreateEventViewController: UIViewController, CreateEventView {
  
  var onCreateEvent: ((EventId) -> ())?
  
  var onCancel: (() -> ())?
  
  var viewModel: CreateEventViewModel!
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var eventTypePicker: UIPickerView!
  @IBOutlet weak var textView: UITextView!
  
  
  
  
  @objc private func cancel() {
    onCancel?()
  }
  
  @objc private func donePressed() {
//    viewModel.sendEvent(<#T##CLLocationDegrees#>, <#T##CLLocationDegrees#>, <#T##Event.EventType#>, 14400, <#T##String#>)
  }
  
  let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: nil)
  
  private func setInitialState() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
    navigationItem.rightBarButtonItem = doneButton
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setInitialState()
  }
  
  
  
  
}
