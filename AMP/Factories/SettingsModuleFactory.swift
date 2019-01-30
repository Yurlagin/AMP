//
//  SettingsModuleFactory.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 28.01.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

protocol SettingsModuleFactory {
  func makeSettingsOutput() -> SettingsRootView
  func makeEditUserProfileOutput() -> UserInfoView
}

