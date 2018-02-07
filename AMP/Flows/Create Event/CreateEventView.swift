//
//  CreateEventView.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 28.01.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import Foundation

protocol CreateEventView: BaseView {
  var onCreateEvent: ((Int) -> ())? { get set }
  var onCancel: (()->())? { get set }
}
