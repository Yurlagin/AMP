//
//  UIImage+Hex.swift
//  Egg
//
//  Created by Pavel Shatalov on 08.12.2017.
//  Copyright © 2017 Pavel Shatalov. All rights reserved.
//

import UIKit

extension UIColor {
  static func hexColor(rgb: Int) -> UIColor {
    return UIColor(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgb & 0xFF00) >> 8) / 255.0, blue: CGFloat((rgb & 0xFF)) / 255.0, alpha: 1.0)
  }
}

