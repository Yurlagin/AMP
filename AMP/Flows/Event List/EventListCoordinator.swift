
import Foundation

final class EventListCoordinator: BaseCoordinator {
  
  private let factory: EventListModuleFactory
  private let router: Router
  
  init(router: Router, factory: EventListModuleFactory) {
    self.factory = factory
    self.router = router
  }
  
  override func start() {
    showEventList()
  }
  
  //MARK: - Run current flow's controllers
  
  private func showEventList() {
    let eventListOutput = factory.makeEventListOutput()
    eventListOutput.onSelectItem = { _ in }
    router.setRootModule(eventListOutput)
  }
    
}
