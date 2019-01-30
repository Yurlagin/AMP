//
//  SettingsRootView.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 25/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import Foundation

import Foundation

protocol SettingsRootView: BaseView {
  var onSelect: ((SettingsRootViewMenuItem) -> ())? { get set }
}

enum SettingsRootViewMenuItem {
  case profile
  case notifications
}
