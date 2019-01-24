//
//  CreateEventState.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 23/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import Foundation

import ReSwift

func createEventReducer(action: Action, state: CreateEventState?) -> CreateEventState {
  var state = state ?? CreateEventState(creationState: .draft,
                                        draft: CreateEventState.EventDraft.createEmptyDraft())
  
  switch action {
  case _ as ReSwiftInit:
    break
    
  case let action as ChangeCreatingEventText:
    state.draft.message = action.text
    
  case let action as ChangeCreatingEventType:
    state.draft.type = action.type
    
  case let action as ChangeCreatingEventCoordinates:
    state.draft.lat = action.latitude
    state.draft.long = action.longitude
    
  case is PostEvent:
    state.creationState = .sending
    
  case let action as EventPostingResult:
    if case .sending = state.creationState {
      switch action {
      case .done(let event):
        state.creationState = .done(eventId: event.id)
        
      case .error(let error):
        state.creationState = .error(
          errorTitle: "Oops!",
          errorText: error.localizedDescription
        )
      }
    }
    
  case is CancelPostingEvent:
    state.creationState = .draft
    
  case is DidShowEventPostingError:
    state.creationState = .draft
    
  case is DidShowPostedEvent:
    state.creationState = .draft
    state.draft.type = .alerts
    state.draft.message = ""
    
  default:
    break
  }
  
  return state
}
