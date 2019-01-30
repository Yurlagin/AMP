//
//  EventTableView.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 15/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import UIKit

class EventTableView: UITableView {
    
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    endEditing(true)
  }
}
