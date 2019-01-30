//
//  TableKit+Extensions.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 15/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import TableKit
import DifferenceKit

extension TableRow: ContentEquatable where CellType.CellData: Differentiable {
  public func isContentEqual(to source: TableRow<CellType>) -> Bool {
    return item.isContentEqual(to: source.item)
  }
}

extension TableRow: Differentiable where CellType.CellData: Differentiable {
  public typealias DifferenceIdentifier = CellType.CellData.DifferenceIdentifier
  
  public var differenceIdentifier: CellType.CellData.DifferenceIdentifier {
    return self.item.differenceIdentifier
  }
}

extension TableDirector {
  func replaceAllSections(with sections: [TableSection]) {
    self.sections.forEach { _ in
      delete(sectionAt: 0)
    }
    self += sections
  }
}
