//
//  SettingsReducer.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 26/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import ReSwift

func settingsReducer(action: Action, state: SettingsState?) -> SettingsState {
  var state = state ?? SettingsState(
    userInfo: UserInfo.loadFromDefaults(),
    sendingUserInfoStatus: .none,
    isHavingScreen: false
  )
  
  switch action {
  case _ as ReSwiftInit:
    break
    
  case let action as SendUserInfo:
    state.sendingUserInfoStatus = .sending(action.userInfo)
    state.isHavingScreen = true
    
  case is LeftUserInfoScreen:
    state.isHavingScreen = false
    
  case is ShownUserInfoErrorAlert:
    guard case .error = state.sendingUserInfoStatus else {
      assertionFailure("This action can be invoked if sendingUserInfoStatus is equal .error only")
      break
    }
    state.sendingUserInfoStatus = .none
    
  case let result as SendingUserInfoResult:
    switch result {
    case .success:
      guard case .sending(let userInfo) = state.sendingUserInfoStatus else {
        assertionFailure("wtf?!")
        break
      }
      state.userInfo = userInfo
      state.sendingUserInfoStatus = .none
      
    case .error(let error):
      if state.isHavingScreen {
        state.sendingUserInfoStatus = .error(description: error.localizedDescription)
      } else {
        state.sendingUserInfoStatus = .none
      }
    }
    
  case let action as SignedIn:
    state.userInfo = action.userInfo
    
  default:
    break
  }
  
  return state
}
