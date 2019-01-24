import ReSwift

extension CreateEventViewController.Props {
  
  var showHud: Bool {
    if case .sending = self.creationState {
      return true
    }
    return false
  }
  
  var errorAlert: (String, String, onPresent: () -> Void)? {
    if case .error(let title, let text) = self.creationState {
      return (title, text, { store.dispatch(DidShowEventPostingError()) })
    }
    return nil
  }
  
  var isEnabledDoneButton: Bool {
    switch self.creationState {
    case .clean, .draft:
      return !draft.message.isEmpty
      
    default:
      return false
    }
  }
  
  func onChangeEvent(latitude: Double, longitude: Double) {
    store.dispatch(ChangeCreatingEventCoordinates(latitude: latitude, longitude: longitude))
  }
  
  func onDraft(text: String) {
    store.dispatch(ChangeCreatingEventText(text: text))
  }
  
  func onChangeEvent(type: Event.EventType) {
    store.dispatch(ChangeCreatingEventType(type: type))
  }
  
  func onSend() {
    store.dispatch(PostEvent())
  }
  
  func onCancel() {
    store.dispatch(CancelPostingEvent())
  }
  
  func onShowPostedEvent() {
    store.dispatch(DidShowPostedEvent())
  }
}

extension CreateEventViewController: StoreSubscriber {
  func newState(state: AppState) {
    self.props = state.createEventState
  }
}

