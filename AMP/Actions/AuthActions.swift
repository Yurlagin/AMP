import ReSwift

struct WillShowEventAtIndex: Action {
  let index: Int
}

struct RequestSmsAction: Action {
  let phone: String
}

struct RequestTokenAction: Action {
  let smsCode: String
  let verificationId: String
}

struct RequestAnonimousToken: Action { }

struct SetLoginState: Action {
  let state: LoginStatus
  init (_ state: LoginStatus) { self.state = state }
}

struct Logout: Action {  }

struct LogoutErrorAction: Action {
  let error: Error
  init (_ error: Error) { self.error = error }
}

struct UpdateUserProfile: Action {
  let userName: String?
  let about: String?
}

struct DidRecieveFCMToken: Action {
  let token: String
}


struct FcmTokenDelivered: Action { }
