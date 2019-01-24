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
    createEventOutput.onCreateEvent = { [weak self] in self?.showEvent(id: $0) }
    router.setRootModule(createEventOutput)
  }
  
  private func showEvent(id: EventId) {
    let eventDetailOutput = factory.makeEventDetailOutput(eventId: id)
    router.push(eventDetailOutput)
  }
}

