final class ModuleFactoryImp:
  AuthModuleFactory,
  EventListModuleFactory,
  EventMapModuleFactory,
  CreateEventModuleFactory,
  FavouritesModuleFactory,
  SettingsModuleFactory
{
  
  func makeEventListOutput() -> EventListView {
    return EventListTableViewController.controllerFromStoryboard(.list)
  }
  
  func makeEventMapOutput() -> EventMapView {
    return EventsMapViewController.controllerFromStoryboard(.map)
  }
  
  func makeEventDetailOutput(eventId: EventId, screenId: ScreenId) -> EventDetailsView {
    let vc = EventDetailsViewController.controllerFromStoryboard(.list)
    vc.eventId = eventId
    vc.screenId = screenId
    return vc
  }
  
  func makeCreateEventOutput() -> CreateEventView {
    return CreateEventViewController.controllerFromStoryboard(.create)
  }
  
  func makeFavouritesOutput() -> FavouritesView {
    return FavouritesTableViewController.controllerFromStoryboard(.favourites)
  }
  
  func makeSettingsOutput() -> BaseView {
    return SettingsTableViewController.controllerFromStoryboard(.settings)
  }
  
  func makeSignInOutput() -> SignInView {
    let vc = SignInViewController.controllerFromStoryboard(.auth)
    vc.viewModel = SignInViewController.ViewModel(state: store.state.authState)
    return vc
  }
  
}
