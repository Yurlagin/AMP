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
    router.setRootModule(settingsOutput)
  }
  
  //  private func showEnterName() {
  //    let enterNameOutput = factory.makeEnterNameOutput()
  //    enterNameOutput.onComplete = { [weak self] firstName, lastName in
  //      guard let weakSelf = self, let storage = weakSelf.storage else { return }
  //      weakSelf.showSendSMSCode(firstName: firstName, lastName: lastName, msisdn: storage.msisdn)
  //    }
  //    router.push(enterNameOutput)
  //  }
  //
  
}

