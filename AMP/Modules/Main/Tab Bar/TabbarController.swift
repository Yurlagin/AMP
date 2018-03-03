import UIKit

final class TabbarController: UITabBarController, UITabBarControllerDelegate, TabbarView {
  
  fileprivate var previosIndex = 0
  
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
  
  

  func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    
    previosIndex = selectedIndex
    return true
  }

  
  
  func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    if let _ = toVC as?  CreateEventNavigationController {
      return AddEventTransitioningIn()
    }
    
    if let _ = fromVC as? CreateEventNavigationController {
      return AddEventTransitioningOut()
    }
    
    return nil
  }
  
  
  
  
  
}
