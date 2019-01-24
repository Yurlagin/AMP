import UIKit

extension UIViewController {
  
  private class func instantiateControllerInStoryboard<T: UIViewController>(_ storyboard: UIStoryboard, identifier: String) -> T {
    return storyboard.instantiateViewController(withIdentifier: identifier) as! T
  }
  
  class func controllerInStoryboard(_ storyboard: UIStoryboard, identifier: String) -> Self {
    return instantiateControllerInStoryboard(storyboard, identifier: identifier)
  }
  
  class func controllerInStoryboard(_ storyboard: UIStoryboard) -> Self {
    return controllerInStoryboard(storyboard, identifier: nameOfClass)
  }
  
  class func controllerFromStoryboard(_ storyboard: Storyboards) -> Self {
    return controllerInStoryboard(UIStoryboard(name: storyboard.rawValue, bundle: nil), identifier: nameOfClass)
  }
}

extension UIViewController {
  
//  func showOkAlert(title: String?, description: String?) {
//    let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
//    alert.addAction(UIAlertAction(title: "Ok", style: .default))
//    present(alert, animated: true)
//  }
  
  func showOkAlert(title: String?, message: String?, okCompletion: (() -> Void)? = nil) {
    let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in
      okCompletion?()
    }
    alertVC.addAction(okAction)
    present(alertVC, animated: true)
  }
  
}

extension UIViewController {
  var topBarHeight: CGFloat {
    let navBarHeight = navigationController?.navigationBar.frame.height ?? 0
    let stastusBarHeight = UIApplication.shared.statusBarFrame.height
    return stastusBarHeight + navBarHeight
  }
  
  var tabbarHeight: CGFloat {
    return tabBarController?.tabBar.frame.height ?? 0
  }
}
