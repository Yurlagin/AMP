//
//  UserProfileViewModel.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 11.03.2018.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import Foundation

extension UserProfileTableViewController {
  struct Props {
    let userInfo: UserInfo
    let canEditProfile: Bool
    let showHud: Bool
    let errorAlert: (title: String?, text: String)?
    
    let onLogout: (() -> Void)?
    let onSelectAvatar: ((Data) -> Void)?
    let onSendUserInfo: (_ userInfo: UserInfo) -> ()
    let onShowError: () -> Void
    let onLeaveScreen: () -> Void
    
    init? (state: AppState) {
      guard let userCredentials = state.authState.loginStatus.userCredentials else { return nil }
      self.userInfo = state.settingsState.userInfo
      self.canEditProfile = userCredentials.level >= 5
      self.showHud = {
        if case .sending = state.settingsState.sendingUserInfoStatus {
          return true
        }
        return false
      }()
      
      self.onLogout = {
        store.dispatch { (state, store) in
          guard let logoutStatus = state.authState.loginStatus.logoutStatus else { return nil }
          switch logoutStatus {
          case .error, .none: return Logout()
          case .request: return nil
          }
        }
      }
      
      self.onSelectAvatar = { imageData in }
      self.onSendUserInfo = { store.dispatch(SendUserInfo($0)) }
      self.errorAlert = {
        guard case .error = state.settingsState.sendingUserInfoStatus else  { return nil } //TODO: - add error handler
        return (title: "Oops!", text: "Something went wrong. Please try later")
      }()
      self.onShowError = { store.dispatch(ShownUserInfoErrorAlert()) }
      self.onLeaveScreen = { store.dispatch(LeftUserInfoScreen()); print("on leave screen") }
    }
  }
}
