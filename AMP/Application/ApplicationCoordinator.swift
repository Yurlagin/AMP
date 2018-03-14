
import ReSwift
import UserNotifications

fileprivate enum LaunchInstructor {
  case main, auth
  static func configure (state: AppState) -> LaunchInstructor {
    if case .loggedIn = state.authState.loginStatus {
      return .main
    }
    return .auth
  }
}

final class ApplicationCoordinator: BaseCoordinator {
  
  private let coordinatorFactory: CoordinatorFactory
  private let router: Router
  
  fileprivate var instructor: LaunchInstructor! {
    didSet {
      if oldValue != instructor { start() }
    }
  }
  
  init(router: Router, coordinatorFactory: CoordinatorFactory) {
    self.router = router
    self.coordinatorFactory = coordinatorFactory
  }
  
  override func start(with option: DeepLinkOption?) {
    
    guard subscribed else {
      store.subscribe(self)
      subscribed = true
      start(with: option)
      return
    }
    
    // start with deepLink
    if let option = option {
      switch option {
      case .signUp: runAuthFlow()
      default: childCoordinators.forEach { coordinator in
        coordinator.start(with: option)
        }
      }
    } else {
      switch instructor! {
      case .auth: runAuthFlow()
      case .main: runMainFlow()
      }
    }
  }
  
  private var subscribed = false
  
  private func runAuthFlow() {
    let coordinator = coordinatorFactory.makeAuthCoordinatorBox(router: router)
    coordinator.finishFlow = { [weak self, weak coordinator] in
      self?.removeDependency(coordinator)
      self?.start()
    }
    addDependency(coordinator)
    coordinator.start()
  }
  
  
  private func runMainFlow() {
    let (coordinator, module) = coordinatorFactory.makeTabbarCoordinator()
    addDependency(coordinator)
    router.setRootModule(module, hideBar: true)
    coordinator.start()
  }
}

extension ApplicationCoordinator: StoreSubscriber {
  
  func newState(state: AppState) {
    instructor = LaunchInstructor.configure(state: state)
  }
  
}
