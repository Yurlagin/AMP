import UIKit

class TabbarCoordinator: BaseCoordinator, TabbarCoordinatorOutput {
  
  private let tabbarView: TabbarView
  private let coordinatorFactory: CoordinatorFactory

  var finishFlow: (() -> ())?

  private let locationTracker = LocationTracker()
  
  init(tabbarView: TabbarView, coordinatorFactory: CoordinatorFactory) {
    self.tabbarView = tabbarView
    self.coordinatorFactory = coordinatorFactory
    locationTracker.startForegroundTracking()
  }
  
  
  override func start() {
    tabbarView.onViewDidLoad = runEventListFlow()
    tabbarView.onEventsListFlowSelect = runEventListFlow()
    tabbarView.onEventsMapFlowSelect = runEventMapFlow()
    tabbarView.onCreateEventFlowSelect = runCreateEventFlow()
    tabbarView.onFavoritesFlowSelect = runFavoritesFlow()
    tabbarView.onSettingsFlowSelect = runSettingsFlow()
  }
  
  override func start(with option: DeepLinkOption?) {

    guard let option = option else {
      start()
      return
    }
    
    switch option {
    default:
      start()
    }
    
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
        let mapCoordinator = self.coordinatorFactory.makeEventMapCoordinator(navController: navController)
        mapCoordinator.start()
        self.addDependency(mapCoordinator)
      }
    }
  }
  
  
  private func runCreateEventFlow() -> ((UINavigationController) -> ()) {
    return { navController in
      if navController.viewControllers.isEmpty == true {
        let createEventCoordinator = self.coordinatorFactory.makeCreateEventCoordinatorBox(navController: navController)
        createEventCoordinator.finishFlow = { [weak self] created in
          if created {
//            self?.tabbarView.selectEventsMapFlow()
            
          } else {
            self?.tabbarView.backToPreviosTab()
          }
        }
        createEventCoordinator.start()
        self.addDependency(createEventCoordinator)
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
