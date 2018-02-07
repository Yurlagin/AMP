
import ReSwift

fileprivate var isAuthorized  = false

fileprivate enum LaunchInstructor {
  case main, auth
  static func configure (isAutorized: Bool) -> LaunchInstructor {
    return isAutorized ? .main : .auth
  }
}

final class ApplicationCoordinator: BaseCoordinator {
  
  private let coordinatorFactory: CoordinatorFactory
  private let router: Router
  
  private var instructor: LaunchInstructor {
    return LaunchInstructor.configure(isAutorized: isAuthorized)
  }
  
  init(router: Router, coordinatorFactory: CoordinatorFactory) {
    self.router = router
    self.coordinatorFactory = coordinatorFactory
  }
  
  override func start(with option: DeepLinkOption?) {
    //start with deepLink
    if let option = option {
      switch option {
      case .signUp: runAuthFlow()
      default: childCoordinators.forEach { coordinator in
        coordinator.start(with: option)
        }
      }
    } else {
      switch instructor {
      case .auth: runAuthFlow()
      case .main: runMainFlow()
      }
    }
  }
  
  private func runAuthFlow() {
    let coordinator = coordinatorFactory.makeAuthCoordinatorBox(router: router)
    coordinator.finishFlow = { [weak self, weak coordinator] in
      isAuthorized = true
      self?.removeDependency(coordinator)
      self?.start()
    }
    addDependency(coordinator)
    coordinator.start()
  }
  
  
  private func runMainFlow() {
    let (coordinator, module) = coordinatorFactory.makeTabbarCoordinator()
//    coordinator.cancelFlow = { [weak self] in
//      isAuthorized = false
//      self?.removeDependency(coordinator)
//      self?.start()
//    }
    store.subscribe(self)
    addDependency(coordinator)
    router.setRootModule(module, hideBar: true)
    coordinator.start()
  }
}

extension ApplicationCoordinator: StoreSubscriber {
  
  func newState(state: AppState) {
    if case .none = state.authState.loginStatus {
      store.unsubscribe(self)
      childCoordinators.forEach { removeDependency($0) }
      isAuthorized = false
      start()
    }
  }
  
}
