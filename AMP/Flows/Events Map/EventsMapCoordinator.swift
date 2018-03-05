
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
    eventsMapOutput.onSelectItem = { [weak self] eventId in
      self?.showEventDetails(eventId: eventId)
    }
    router.setRootModule(eventsMapOutput)
  }
  
  
  private func showEventDetails(eventId: EventId) {
    let screenId = UUID().uuidString
    let vcOutput = factory.makeEventDetailOutput(eventId: eventId, screenId: screenId)
    store.dispatch(CreateCommentsScreen(screenId: screenId, eventId: eventId))
    vcOutput.eventId = eventId
    vcOutput.screenId = screenId
    store.dispatch(CreateCommentsScreen(screenId: screenId, eventId: eventId))
    router.push(vcOutput)
  }
    
}

