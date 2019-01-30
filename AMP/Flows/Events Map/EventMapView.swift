//
//  EventMapView.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 28.01.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import Foundation

protocol EventSelectable: BaseView {
  var onSelect: ((EventId) -> ())? { get set }
}

protocol EventMapView: EventSelectable {
}
