import UIKit

final class TabbarController: UITabBarController, UITabBarControllerDelegate, TabbarView {
  
  var onEventsListFlowSelect: ((UINavigationController) -> ())?
  
  var onEventsMapFlowSelect: ((UINavigationController) -> ())?
  
  var onCreateEventFlowSelect: ((UINavigationController) -> ())?
  
  var onFavoritesFlowSelect: ((UINavigationController) -> ())?
  
  var onSettingsFlowSelect: ((UINavigationController) -> ())?
  
  var onViewDidLoad: ((UINavigationController) -> ())?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    delegate = self
    if let controller = customizableViewControllers?.first as? UINavigationController {
      onViewDidLoad?(controller)
    }
  }
  
  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    guard let controller = viewControllers?[selectedIndex] as? UINavigationController else { return }
    
    switch selectedIndex {
    case 0:
      onEventsListFlowSelect?(controller)
    case 1:
      onEventsMapFlowSelect?(controller)
    case 2:
      onCreateEventFlowSelect?(controller)
    case 3:
      onFavoritesFlowSelect?(controller)
    case 4:
      onSettingsFlowSelect?(controller)

    default:
      break
    }
  }
}
