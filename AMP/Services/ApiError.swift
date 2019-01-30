//
//  ApiError.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 05/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import Foundation

enum ApiError: Error {
  case noBaseURL
  case network(underlyingError: Error) 
  case parsingError(underlyingError: Error?)
  case noToken
}
