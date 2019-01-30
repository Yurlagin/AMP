//
//  SignInModuleOutput.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 04/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import Foundation

protocol SignInModuleOutput: class {
  var onComplete: (() -> Void)? { get set }
}
