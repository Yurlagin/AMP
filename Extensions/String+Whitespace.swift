//
//  String+Whitespace.swift
//  Egg
//
//  Created by Pavel Shatalov on 12.12.2017.
//  Copyright © 2017 Pavel Shatalov. All rights reserved.
//

import Foundation

extension String {
  
  func className() -> String {
    return self.components(separatedBy: ".").last ?? self
  }
  
  func stringByTrimingWhitespace() -> String {
    return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    
  }
  
  var removeWhitespacesFromText: String {
    let components = self.components(separatedBy: CharacterSet.whitespacesAndNewlines)
    let filtered = components.filter({!$0.isEmpty})
    return filtered.joined(separator: " ")
  }
}
