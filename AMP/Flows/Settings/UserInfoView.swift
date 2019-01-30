//
//  UserInfoView.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 28/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import Foundation

protocol UserInfoView: BaseView {
  var onDone: (() -> Void)? { get set }
}
