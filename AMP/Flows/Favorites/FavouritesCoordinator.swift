//
//  FavouritesCoordinator.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 28.01.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import Foundation

final class FavouritesCoordinator: BaseCoordinator {
    
  private let factory: FavouritesModuleFactory
  private let router: Router
  
  init(router: Router, factory: FavouritesModuleFactory) {
    self.factory = factory
    self.router = router
  }
  
  override func start() {
    showFavourites()
  }
  
  //MARK: - Run current flow's controllers
  
  private func showFavourites() {
    let favouritesOutput = factory.makeFavouritesOutput()
    router.setRootModule(favouritesOutput)
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

