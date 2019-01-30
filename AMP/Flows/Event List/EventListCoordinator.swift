
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
  
  private func showEventList() {
    let eventListOutput = factory.makeEventListOutput()
    eventListOutput.onSelect = { [weak self] in self?.showEventDetails(id: $0, showKeyboard: false) }
    eventListOutput.onTapComment = { [weak self] in self?.showEventDetails(id: $0, showKeyboard: true) }
    router.setRootModule(eventListOutput)
  }
  
  private func showEventDetails(id: EventId, showKeyboard: Bool) {
    let eventOutput = factory.makeEventDetailOutput(eventId: id)
    router.push(eventOutput)
  }

}
