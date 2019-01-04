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
  
  private func showSighInForm() {
    let (signInView, moduleOutput) = factory.makeSignInOutput()
    moduleOutput.onComplete = finishFlow
    router.setRootModule(signInView)
  }
  
}
