import UIKit

final class CoordinatorFactoryImp: CoordinatorFactory {
  

  func makeTabbarCoordinator() -> (configurator: Coordinator & TabbarCoordinatorOutput, toPresent: Presentable?) {
    let controller = TabbarController.controllerFromStoryboard(.main)
    let coordinator = TabbarCoordinator(tabbarView: controller, coordinatorFactory: CoordinatorFactoryImp())
    return (coordinator, controller)
  }
  
  func makeAuthCoordinatorBox(router: Router) -> Coordinator & AuthCoordinatorOutput {
    let coordinator = AuthCoordinator(router: router, factory: ModuleFactoryImp())
    return coordinator
  }
  
  func makeEventListCoordinator(navController: UINavigationController) -> Coordinator {
    let coordinator = EventListCoordinator(router: router(navController), factory: ModuleFactoryImp())
    return coordinator
  }
  
  func makeEventMapCoordinator(navController: UINavigationController) -> Coordinator {
    return EventsMapCoordinator(router: router(navController), factory: ModuleFactoryImp())
  }
  
  func makeCreateEventCoordinatorBox(navController: UINavigationController) -> Coordinator & CreateEventCoordinatorOutput {
    return CreateEventCoordinator(router: router(navController), factory: ModuleFactoryImp())
  }
  
  func makeFavoritesCoordinator(navController: UINavigationController) -> Coordinator {
    return FavouritesCoordinator(router: router(navController), factory: ModuleFactoryImp())
  }
  
  func makeSettingsCoordinator(navController: UINavigationController) -> Coordinator {
    return SettingsCoordinator(router: router(navController), factory: ModuleFactoryImp())
  }
  
  private func router(_ navController: UINavigationController?) -> Router {
    return RouterImp(rootController: navigationController(navController))
  }
  
  private func navigationController(_ navController: UINavigationController?) -> UINavigationController {
    if let navController = navController { return navController }
    else { return UINavigationController.controllerFromStoryboard(.main) }
  }
}
