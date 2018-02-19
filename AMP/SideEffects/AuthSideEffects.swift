//
//  AuthSideEffects.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 27.01.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import ReSwift

func requestSms(authService: AuthServiceProtocol) -> MiddlewareItem {
  return { (action: Action, dispatch: @escaping DispatchFunction) in
    
    switch action {
      
    case let action as RequestSmsAction:

      let (promise, _) = authService.getAuthCode(for: action.phone)
      
      promise
        .then { dispatch(SetLoginState(.phoneFlow(.smsRequestSuccess(verificationId: $0)))) }
        .catch { dispatch(SetLoginState(.phoneFlow(.smsRequestFail($0)))) }
      
    default:
      break
    }
  }
}


func logIn(authService: AuthServiceProtocol) -> MiddlewareItem {
  return { (action: Action, dispatch: @escaping DispatchFunction) in
   
    let bgQeue = DispatchQueue.global(qos: .userInitiated)

    switch action {
      
    case let action as RequestTokenAction:
      
      authService.login(smsCode: action.smsCode, verificationId: action.verificationId)
        .then (on: bgQeue) { authService.store(userCredentials: $0) }
        .then { dispatch(SetLoginState(.loggedIn(user: $0, logoutStatus: .none))) }
        .catch { dispatch(SetLoginState(.phoneFlow(.requestTokenFail(verificationId: action.verificationId, $0)))) }

    case _ as RequestAnonimousToken:
      
      authService.signInAnonymously()
        .then (on: bgQeue) { authService.store(userCredentials: $0) }
        .then { dispatch(SetLoginState(.loggedIn(user: $0, logoutStatus: .none))) }
        .catch { dispatch(SetLoginState(.anonimousFlow(.failed($0)))) }
      
    case _ as Logout:
      
      authService.logout()
        .then { dispatch (SetLoginState(.none)) }
        .catch { dispatch (LogoutErrorAction($0)) }
      
    default:
      break
    }
  }
}



func getComments(eventsService: EventsServiceProtocol) -> MiddlewareItem {
  return { (action: Action, dispatch: @escaping DispatchFunction) in
    
    switch action {
      
    case let action as CreateCommentsScreen:
      guard let token = store.state.authState.loginStatus.getUserCredentials()?.token else { return }
      eventsService.makeRequest(CommentsRequest(eventid: action.eventId, token: token, filter: CommentsRequest.CommentsFilter(limit: 10, offset: 0, maxid: nil)))
        .then {
          dispatch(NewComments(screenId: action.screenId, comments: $0, action: .replace)) }
        .catch { _ in
          dispatch(GetCommentsError(screenId: action.screenId)) }
      
    default:
      break
      
    }
    
  }
  
}

