
import Foundation

final class EventsMapCoordinator: BaseCoordinator {
  
  private let factory: EventMapModuleFactory
  private let router: Router
  
  init(router: Router, factory: EventMapModuleFactory) {
    self.factory = factory
    self.router = router
  }
  
  override func start() {
    showEventsMap()
  }
  
  //MARK: - Run current flow's controllers
  
  private func showEventsMap() {
    let eventsMapOutput = factory.makeEventMapOutput()
    eventsMapOutput.onSelect = { [weak self] eventId in
      self?.showEventDetails(id: eventId)
    }
    router.setRootModule(eventsMapOutput)
  }
  
  private func showEventDetails(id: EventId, showKeyboard: Bool = true) {
    let eventVcOutput = factory.makeEventDetailOutput(eventId: id)
    router.push(eventVcOutput)
  }

}

