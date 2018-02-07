final class CreateEventCoordinator: BaseCoordinator, CreateEventCoordinatorOutput {
    
  private let factory: CreateEventModuleFactory
  private let router: Router
  
  var finishFlow: (() -> Void)? 
  
  init(router: Router, factory: CreateEventModuleFactory) {
    self.factory = factory
    self.router = router
  }
  
  override func start() {
    showSighInForm()
  }
  
  //MARK: - Run current flow's controllers
  
  private func showSighInForm() {
    let createEventOutput = factory.makeCreateEventOutput()
    
    //TODO: Добавить обработку добавленного события и отмены
    router.setRootModule(createEventOutput)
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

