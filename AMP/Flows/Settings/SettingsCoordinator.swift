//
//  FavouritesCoordinator.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 28.01.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import Foundation

final class SettingsCoordinator: BaseCoordinator {
  
  
  private let factory: SettingsModuleFactory
  private let router: Router
  
  init(router: Router, factory: SettingsModuleFactory) {
    self.factory = factory
    self.router = router
  }
  
  override func start() {
    showSettings()
  }
  
  //MARK: - Run current flow's controllers
  
  private func showSettings() {
    let settingsOutput = factory.makeSettingsOutput()
    settingsOutput.onSelect = { [weak self] item in
      switch item {
      case .profile: self?.showEditProfileScreen()
      case .notifications: self?.showNotificationsSettings()
      }
    }
    router.setRootModule(settingsOutput)
  }
  
  private func showEditProfileScreen() {
    let userProfileOutput = factory.makeEditUserProfileOutput()
    userProfileOutput.onDone = { [weak userProfileOutput, weak self] in
      if userProfileOutput != nil {
        self?.router.popModule()
      }
    }
    router.push(userProfileOutput)
  }
  
  private func showNotificationsSettings() {
    
  }
  
}

