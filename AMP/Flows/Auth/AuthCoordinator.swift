final class AuthCoordinator: BaseCoordinator, AuthCoordinatorOutput {
  
  var finishFlow: (() -> ())?
  
  private let factory: AuthModuleFactory
  private let router: Router
  
  init(router: Router, factory: AuthModuleFactory) {
    self.factory = factory
    self.router = router
  }
  
  override func start() {
    showSighInForm()
  }
  
  //MARK: - Run current flow's controllers
  
  private func showSighInForm() {
    let signInOutput = factory.makeSignInOutput()
    signInOutput.onComplete = finishFlow
    router.setRootModule(signInOutput)
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
