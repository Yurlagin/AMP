import UIKit

class TabbarCoordinator: BaseCoordinator, TabbarCoordinatorOutput {
  
  private let tabbarView: TabbarView
  private let coordinatorFactory: CoordinatorFactory

  var cancelFlow: (() -> ())?

  
  init(tabbarView: TabbarView, coordinatorFactory: CoordinatorFactory) {
    self.tabbarView = tabbarView
    self.coordinatorFactory = coordinatorFactory
  }
  
  override func start() {
    tabbarView.onViewDidLoad = runEventListFlow()
    tabbarView.onEventsListFlowSelect = runEventListFlow()
    tabbarView.onEventsMapFlowSelect = runEventMapFlow()
    tabbarView.onCreateEventFlowSelect = runCreateEventFlow()
    tabbarView.onFavoritesFlowSelect = runFavoritesFlow()
    tabbarView.onSettingsFlowSelect = runSettingsFlow()
  }
  
  private func runEventListFlow() -> ((UINavigationController) -> ()) {
    return { navController in
      if navController.viewControllers.isEmpty == true {
        let itemCoordinator = self.coordinatorFactory.makeEventListCoordinator(navController: navController )
        itemCoordinator.start()
        self.addDependency(itemCoordinator)
      }
    }
  }
  
  private func runEventMapFlow() -> ((UINavigationController) -> ()) {
    return { navController in
      if navController.viewControllers.isEmpty == true {
        let settingsCoordinator = self.coordinatorFactory.makeEventMapCoordinator(navController: navController)
        settingsCoordinator.start()
        self.addDependency(settingsCoordinator)
      }
    }
  }
  
  private func runCreateEventFlow() -> ((UINavigationController) -> ()) {
    return { navController in
      if navController.viewControllers.isEmpty == true {
        let settingsCoordinator = self.coordinatorFactory.makeCreateEventCoordinatorBox(navController: navController)
        settingsCoordinator.start()
        self.addDependency(settingsCoordinator)
      }
    }
  }
  
  private func runFavoritesFlow() -> ((UINavigationController) -> ()) {
    return { navController in
      if navController.viewControllers.isEmpty == true {
        let settingsCoordinator = self.coordinatorFactory.makeFavoritesCoordinator(navController: navController)
        settingsCoordinator.start()
        self.addDependency(settingsCoordinator)
      }
    }
  }
  
  private func runSettingsFlow() -> ((UINavigationController) -> ()) {
    return { navController in
      if navController.viewControllers.isEmpty == true {
        let settingsCoordinator = self.coordinatorFactory.makeSettingsCoordinator(navController: navController)
        settingsCoordinator.start()
        self.addDependency(settingsCoordinator)
      }
    }
  }
}
