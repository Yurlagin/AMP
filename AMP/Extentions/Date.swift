//
//  Date.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 16.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import Foundation

extension Date {
  init?(ampDateString: String) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    guard let date = dateFormatter.date(from: ampDateString) else { return nil }
    self = date
  }
}
