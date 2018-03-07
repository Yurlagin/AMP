import Foundation

struct DeepLinkURLConstants {
  static let ShowEventOnMap = "showEventOnMap"
  static let Onboarding = "onboarding"
  static let Items = "items"
  static let Chat = "chat"
  static let Settings = "settings"
  static let Login = "login"
  static let Terms = "terms"
  static let SignUp = "signUp"
}

enum DeepLinkOption {
  case showEventOnMap(EventId?)
  case onboarding
  case items
  case settings
  case login
  case terms
  case signUp
  case chat(String?)
  
  static func build(with userActivity: NSUserActivity) -> DeepLinkOption? {
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
      let url = userActivity.webpageURL,
      let _ = URLComponents(url: url, resolvingAgainstBaseURL: true) {
      //TODO: extract string and match with DeepLinkURLConstants
    }
    return nil
  }
  
  static func build(with dict: [String : AnyObject]?) -> DeepLinkOption? {
    guard let id = dict?["launch_id"] as? String else { return nil }
    
    let chatID = dict?["chatId"] as? String
    let eventId = dict?["eventId"] as? Int
    
    switch id {
    case DeepLinkURLConstants.ShowEventOnMap: return .showEventOnMap(eventId)
      case DeepLinkURLConstants.Onboarding: return .onboarding
      case DeepLinkURLConstants.Items: return .items
      case DeepLinkURLConstants.Chat: return .chat(chatID)
      case DeepLinkURLConstants.Settings: return .settings
      case DeepLinkURLConstants.Login: return .login
      case DeepLinkURLConstants.Terms: return .terms
      case DeepLinkURLConstants.SignUp: return .signUp
      default: return nil
    }
  }
}
