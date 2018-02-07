
import Foundation

final class EventsMapCoordinator: BaseCoordinator {
  
  private let factory: EventMapModuleFactory
  private let router: Router
  
  init(router: Router, factory: EventMapModuleFactory) {
    self.factory = factory
    self.router = router
  }
  
  override func start() {
    showEventList()
  }
  
  //MARK: - Run current flow's controllers
  
  private func showEventList() {
    let eventsMapOutput = factory.makeEventMapOutput()
    eventsMapOutput.onSelectItem = { _ in }
    router.setRootModule(eventsMapOutput)
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

