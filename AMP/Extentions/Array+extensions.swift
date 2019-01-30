//
//  Array+extensions.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 11/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
  func asSet() -> Set<Element> {
    return Set(self)
  }
}
