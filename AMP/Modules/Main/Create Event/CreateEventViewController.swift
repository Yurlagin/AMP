//
//  CreateEventViewController.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 28.01.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import UIKit

class CreateEventViewController: UIViewController, CreateEventView {
  
  var onCreateEvent: ((Int) -> ())?
  
  var onCancel: (() -> ())?
  
  
  @objc private func cancel() {
    onCancel?()
  }
  
  
  private func setInitialState() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setInitialState()
  }
  
  
  
  
}
