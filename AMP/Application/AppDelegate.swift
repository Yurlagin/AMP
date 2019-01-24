import ReSwift
import Firebase
import UserNotifications

let authSideEffects = injectService(service: AuthServiceImpl(authStorage: AuthStorageImpl()),
                                    receivers: authServiceSideEffects)
let eventsSideEffects = injectService(service: ApiServiceImpl(), receivers: eventsServiceSideEffects)

let middleware = createMiddleware(items: authSideEffects + eventsSideEffects)

let store = Store (
  reducer: appReducer,
  state: nil,
  middleware: [middleware])


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  var rootController: UINavigationController {
    return self.window!.rootViewController as! UINavigationController
  }
  
  private lazy var applicationCoordinator: Coordinator = self.makeCoordinator()
  
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    
    UNUserNotificationCenter.current().delegate = self
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (_, _) in }
    application.registerForRemoteNotifications()
    
    Messaging.messaging().delegate = self
    
    let notification = launchOptions?[.remoteNotification] as? [String: AnyObject]
    let deepLink = DeepLinkOption.build(with: notification)
    applicationCoordinator.start(with: deepLink)
    return true
  }
  
  private func makeCoordinator() -> Coordinator {
    return ApplicationCoordinator(
      router: RouterImp(rootController: self.rootController),
      coordinatorFactory: CoordinatorFactoryImp()
    )
  }
  
  // MARK: - Handle push notifications and deep links
  
  func application(_ application: UIApplication,
                   didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
    let dict = userInfo as? [String: AnyObject]
    let deepLink = DeepLinkOption.build(with: dict)
    applicationCoordinator.start(with: deepLink)
  }
  
  
  func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                   restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    let deepLink = DeepLinkOption.build(with: userActivity)
    applicationCoordinator.start(with: deepLink)
    return true
  }
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    
    print (userInfo)
    
    if let type = userInfo["notitype"] as? String {
      
      var id: String?
      
      switch type {
      case "eventcreate": id = userInfo["eventid"] as? String
      case "commentcreate": id = userInfo["comid"] as? String
      default: break
      }
      
      if let id = id {
        let content = UNMutableNotificationContent()
        content.title = userInfo["title"] as? String ?? ""
        content.body = userInfo["body"] as? String ?? ""
        let request = UNNotificationRequest(identifier: type + id, content: content, trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false))
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
      }

    }
    completionHandler(.noData)
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
 
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    print (notification)
    completionHandler([.alert])
  }
  
}

extension AppDelegate: MessagingDelegate {
  
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    store.dispatch(DidRecieveFCMToken(token: fcmToken))
  }
  
  func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
    print (remoteMessage)
//    remoteMessage.appData
  }
}
