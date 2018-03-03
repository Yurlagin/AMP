//
//  CreateEventCoordinatorOutput.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 29.01.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

protocol CreateEventCoordinatorOutput: class {
  
  typealias Created = Bool
  
  var finishFlow: ((Created) -> Void)? { get set }
  
}

