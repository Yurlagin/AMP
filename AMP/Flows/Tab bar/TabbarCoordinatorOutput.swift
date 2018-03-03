//
//  TabbarCoordinatorOutput.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 07.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

protocol TabbarCoordinatorOutput: class {
  var finishFlow: (() -> Void)? { get set }
}

