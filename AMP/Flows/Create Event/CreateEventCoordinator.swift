final class CreateEventCoordinator: BaseCoordinator, CreateEventCoordinatorOutput {
    
  private let factory: CreateEventModuleFactory
  private let router: Router
  
  var finishFlow: ((Created) -> Void)?
  
  init(router: Router, factory: CreateEventModuleFactory) {
    self.factory = factory
    self.router = router
  }
  
  override func start() {
    showCreateEventForm()
  }
  
  //MARK: - Run current flow's controllers
  
  private func showCreateEventForm() {
    let createEventOutput = factory.makeCreateEventOutput()
    createEventOutput.onCancel = { [weak self] in self?.finishFlow?(false) }
    
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

