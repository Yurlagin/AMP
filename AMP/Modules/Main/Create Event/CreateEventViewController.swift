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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  
}
