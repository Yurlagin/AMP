//
//  UINavigationControllerExtensions.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 15.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import UIKit

extension UINavigationController {
  
  override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    get {
      return self.topViewController?.supportedInterfaceOrientations ?? .all
    }
  }
  
  override open var shouldAutorotate: Bool {
    return self.topViewController?.shouldAutorotate ?? false
  }
  
  
}
