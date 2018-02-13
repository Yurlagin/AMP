//
//  UIColor.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 13.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import UIKit

extension UIColor {
  
  static func hexColor(rgb: Int, alpha: CGFloat) -> UIColor {
    return UIColor(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgb & 0xFF00) >> 8) / 255.0, blue: CGFloat((rgb & 0xFF)) / 255.0, alpha: alpha)
  }
  
}
