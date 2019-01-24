//
//  UserProfileViewModel.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 11.03.2018.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import Foundation
import PromiseKit

struct UserProfileViewModel {
  
  let avatarURL: String?
  let userName: String?
  let about: String?
  let canEditProfile: Bool
  let showHud: Bool

  let didTapLogout: (()->())?
  let didSelectAvatar: ((Data)->())?
  let didPressDoneButton: (_ userName: String?, _ about: String?) -> ()
  private let sendProfileFunction: (String?, String?, String) -> Promise<()>
  
  init? (state: AppState, sendProfileFunction: @escaping (String?, String?, String) -> Promise<()>) {
    guard let user = state.authState.loginStatus.userCredentials else { return nil }
   
    self.sendProfileFunction = sendProfileFunction
    avatarURL = user.avaurl
    userName = user.name
    about = user.about
    canEditProfile = user.level >= 5
    fatalError("implement me")
//    showHud = state.apiRequestsState.setUserProfileSettingsRequest.isRunningRequest()
    
    
    didTapLogout = {
      store.dispatch { (state, store) in
        guard let logoutStatus = state.authState.loginStatus.logoutStatus else { return nil }
        switch logoutStatus {
        case .error, .none: return Logout()
        case .request: return nil
        }
      }
    }
    
    
    didSelectAvatar = { imageData in
      store.dispatch { (state, store) in
        guard let token = state.authState.loginStatus.userCredentials?.token else { return nil }
        ApiServiceImpl().uploadAvatar(imageData: imageData, request: AMPUploadRequest(token: token))
          .then {
            print ($0)
          }.catch {
            print($0)
          }
        return nil
      }
    }
    
    
    didPressDoneButton = { userName, about in
      fatalError("implement me")
//      store.dispatch { state, store in
//        guard let token = state.authState.loginStatus.userCredentials?.token, !state.apiRequestsState.setUserProfileSettingsRequest.isRunningRequest() else { return nil }
//        sendProfileFunction(userName, about, token)
//          .then {
//            store.dispatch(SetUserProfileRequestStatus.success(userName, about))
//          }.catch {
//            store.dispatch(SetUserProfileRequestStatus.error($0))
//        }
//        return SetUserProfileRequestStatus.request
//      }
    }
  }
  
}

extension SetUserProfileRequestStatus {
  
  func isRunningRequest() -> Bool {
    if case .request = self {
      return true
    }
    return false
  }
  
}
