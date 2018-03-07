import UIKit

protocol TabbarView: class {
  var onEventsListFlowSelect: ((UINavigationController) -> ())? { get set }
  var onEventsMapFlowSelect: ((UINavigationController) -> ())? { get set }
  var onCreateEventFlowSelect: ((UINavigationController) -> ())? { get set }
  var onFavoritesFlowSelect: ((UINavigationController) -> ())? { get set }
  var onSettingsFlowSelect: ((UINavigationController) -> ())? { get set }
  var onViewDidLoad: ((UINavigationController) -> ())? { get set }
  
//  func selectEventsMapFlow()
  func backToPreviosTab()
}
