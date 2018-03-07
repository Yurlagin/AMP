//
//  CreateEventCoordinatorOutput.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 29.01.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

typealias Created = Bool

protocol CreateEventCoordinatorOutput: class {
  
  var finishFlow: ((Created) -> Void)? { get set }
  
}

