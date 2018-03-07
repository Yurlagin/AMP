
import UIKit

class AddEventTransitioningIn: NSObject, UIViewControllerAnimatedTransitioning {
  
  private let transitionInterval: TimeInterval = 0.25
  private let dissapearScale: CGFloat = 0.95 // Процент линейного уменьшения fromVC
 
  
  public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return transitionInterval
  }
  

  public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let fromVC = transitionContext.viewController(forKey: .from)!
    let toVC = transitionContext.viewController(forKey: .to)!
    let containerView = transitionContext.containerView
        
    toVC.tabBarController?.tabBar.isHidden = true
    containerView.addSubview(toVC.view)
    toVC.view.frame.origin = CGPoint(x: 0, y: containerView.bounds.maxY)

    UIView.animateKeyframes(withDuration: transitionInterval, delay: 0, options: [], animations: {
      toVC.view.frame.origin = CGPoint(x: 0, y: 0)
      fromVC.view.alpha = 0.5
      fromVC.view.transform = CGAffineTransform(scaleX: self.dissapearScale, y: self.dissapearScale)
    }) { success in
      fromVC.view.transform = CGAffineTransform(scaleX: 1, y: 1)
      fromVC.view.alpha = 1
      transitionContext.completeTransition(true)
    }
  }
  
}
