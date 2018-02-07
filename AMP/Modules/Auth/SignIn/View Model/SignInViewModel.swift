
extension SignInViewController {
  
  struct ViewModel {
    
    var isUserInteractionEnabled = true
    var showHud = false
    
    var phoneFormEnabled = false
    
    var smsFormHidden = true
    var smsFormEnabled = false
    
    var phoneButtonEnabled = true // never mutates
    var anonimousButtonEnabled = true // never mutates
    
    var phoneButtonTapped: ((String?, String?)->())? = nil
    var anonimousButtonTapped: (()->())? = nil
  
    var showAlert: (title: String?, text: String?)?
    
    var isAuthComplete = false
    
    init (state: AuthState) {
      
      isUserInteractionEnabled = !state.loginStatus.isPerformingNetworkRequest()
      showHud = state.loginStatus.isPerformingNetworkRequest()
      
      switch state.loginStatus {
      case .none:
        phoneFormEnabled = true
      case .phoneFlow(let status):
        switch status {
        case .requestSms :
          break
        case .smsRequestFail:
          phoneFormEnabled = true
        case .smsRequestSuccess, .requestToken, .requestTokenFail:
          smsFormHidden = false
          smsFormEnabled = true
        }
      case .loggedIn:
        isAuthComplete = true
      default:
        break
      }
      
      phoneButtonTapped = { phone, code in
        store.dispatch { (state, store) in
          if case .none = state.authState.loginStatus {
            return RequestSmsAction(phone: phone!)
          } else if case .phoneFlow (let status) = state.authState.loginStatus {
            switch status {
            case .smsRequestSuccess(let verificationId), .requestTokenFail(let verificationId, _):
              return RequestTokenAction(smsCode: code!, verificationId: verificationId)
            case .smsRequestFail:
              return RequestSmsAction(phone: phone!)
            default : break
            }
          }
          return nil
        }
      }
      
      anonimousButtonTapped = {
        store.dispatch(RequestAnonimousToken())
      }
      
      if let error = state.loginStatus.currentError() {
        showAlert = (title: "Oops!", text: error.localizedDescription)
      }
    }
  }
}

extension LoginStatus {
  
  func isPerformingNetworkRequest() -> Bool {
    if case .phoneFlow(let status) = self {
      switch status {
      case .requestSms, .requestToken: return true
      default: return false
      }
    } else if case .anonimousFlow(let status) = self, case .request = status {
      return true
    }
    return false
  }
  
  func currentError() -> Error? {
    if case .phoneFlow(let status) = self {
      switch status {
      case .requestTokenFail(_, let error), .smsRequestFail(let error): return error
      default: return nil
      }
    } else if case .anonimousFlow(let status) = self, case .failed(let error) = status {
      return error
    }
    return nil
  }
  
  
  
}

