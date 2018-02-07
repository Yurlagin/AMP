//
//  EnterNameView.swift
//  Egg
//
//  Created by Dmitry Yurlagin on 09.01.18.
//  Copyright © 2018 Pavel Shatalov. All rights reserved.
//

protocol EnterNameView: BaseView {
  
  var onComplete: ((String, String) -> ())? { get set }
  
}
