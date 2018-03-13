//
//  SettingsActions.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 13.03.2018.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift

enum SetUserProfileRequestStatus: Action {
  case none
  case request
  case error(Error)
  case success(String?, String?)
}
