
import UIKit


class AddEventTransitioningOut: NSObject, UIViewControllerAnimatedTransitioning {
  
  private let transitionInterval: TimeInterval = 0.25
  private let dissapearScale: CGFloat = 0.95 // Процент линейного уменьшения toVC

  
  public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return transitionInterval
  }
  
  
  public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    
    let toVC = transitionContext.viewController(forKey: .to)!
    let fromVC = transitionContext.viewController(forKey: .from)!
    let containerView = transitionContext.containerView
    containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
    
    toVC.view.transform = CGAffineTransform(scaleX: dissapearScale, y: dissapearScale)

    UIView.animate(withDuration: transitionInterval, delay: 0, options: [], animations: {
      fromVC.view.frame.origin = CGPoint(x: 0, y: containerView.bounds.maxY)
      toVC.view.alpha = 1
      toVC.view.transform = CGAffineTransform(scaleX: 1, y: 1)
    }) {  success in
//      toVC.tabBarController?.tabBar.isHidden = false
      transitionContext.completeTransition(true)
    }

  }
  
}
