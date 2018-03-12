//
//  UserProfileViewModel.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 11.03.2018.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import Foundation

struct UserProfileViewModel {
  
  let avatarURL: String?
  let userName: String?
  let about: String?
  let canEditProfile: Bool

  let didTapLogout: (()->())?
  let didSelectAvatar: ((Data)->())?
  
  init? (state: AppState) {
    guard let user = state.authState.loginStatus.getUserCredentials() else { return nil }
   
    avatarURL = user.avaurl
    userName = user.name
    about = "Coming soon =]"
    canEditProfile = user.level >= 5
    
    
    didTapLogout = {
      store.dispatch { (state, store) in
        guard let logoutStatus = state.authState.loginStatus.getLogoutStatus() else { return nil }
        switch logoutStatus {
        case .error, .none: return Logout()
        case .request: return nil
        }
      }
    }
    
    
    didSelectAvatar = { imageData in
      store.dispatch { (state, store) in
        guard let token = state.authState.loginStatus.getUserCredentials()?.token else { return nil }
        EventsService.uploadAvatar(imageData: imageData, request: AMPUploadRequest(token: token))
          .then {
            print ($0)
          }.catch {
            print($0)
          }
        return nil
      }
    }
  }
  
}
