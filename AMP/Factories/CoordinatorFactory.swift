import UIKit

protocol CoordinatorFactory {
  
  func makeAuthCoordinatorBox(router: Router) -> Coordinator & AuthCoordinatorOutput
  func makeTabbarCoordinator() -> (configurator: Coordinator & TabbarCoordinatorOutput, toPresent: Presentable?)

  func makeEventListCoordinator(navController: UINavigationController) -> Coordinator
  func makeEventMapCoordinator(navController: UINavigationController) -> Coordinator
  func makeCreateEventCoordinatorBox(navController: UINavigationController) -> Coordinator & CreateEventCoordinatorOutput
  func makeFavoritesCoordinator(navController: UINavigationController) -> Coordinator
  func makeSettingsCoordinator(navController: UINavigationController) -> Coordinator
  
}
