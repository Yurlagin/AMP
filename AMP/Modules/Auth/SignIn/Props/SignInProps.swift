import Firebase

extension SignInViewController {
  
  struct Props {
    
    // MARK: state
    
    var isUserInteractionEnabled = true
    var showHud = false
    
    var phoneFormEnabled = false
    var smsFormHidden = true
    var smsFormEnabled = false
    var isAuthComplete = false
    var phoneButtonEnabled = true // never mutates
    var anonimousButtonEnabled = true // never mutates
    var showAlertPrompt: (title: String?, text: String?)?
    
    // MARK: interaction
    
    var onSingInAttempt: ((_ phone: String?, _ smsCode: String?) -> Void)? = nil
    var onAnonymousAttempt: (() -> ())? = nil
    
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
      
      onSingInAttempt = { phone, code in
        store.dispatch { (state, store) in
          switch state.authState.loginStatus {
          case .none:
            return RequestSmsAction(phone: phone!)

          case .phoneFlow (let status):
            switch status {
            case .smsRequestFail:
              return RequestSmsAction(phone: phone!)
              
            case .smsRequestSuccess(let verificationId):
              return RequestTokenAction(smsCode: code!, verificationId: verificationId)
              
            case .requestTokenFail(let verificationId, _):
                return RequestTokenAction(smsCode: code!, verificationId: verificationId)
              
            default:
              return nil
            }

          case .anonymousFlow, .loggedIn:
            return nil
          }
        }
      }
      
      onAnonymousAttempt = {
        store.dispatch(RequestAnonymousToken())
      }
      
      if let error = state.loginStatus.currentError() {
        showAlertPrompt = (title: "Oops!", text: error.localizedDescription)
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
    } else if case let .anonymousFlow(status) = self, case .loading = status {
      return true
    } else {
      return false
    }
  }
  
  func currentError() -> Error? {
    if case .phoneFlow(let status) = self {
      switch status {
      case .requestTokenFail(_, let error): return error
      case .smsRequestFail(let error): return error
      default: return nil
      }
    } else if case .anonymousFlow(let status) = self, case .fail(let error) = status {
      return error
    } else {
      return nil
    }
  }
}

