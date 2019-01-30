final class ModuleFactoryImp:
  AuthModuleFactory,
  EventListModuleFactory,
  EventMapModuleFactory,
  CreateEventModuleFactory,
  FavouritesModuleFactory,
  SettingsModuleFactory
{
  
  func makeEventListOutput() -> EventListView {
    let eventListVc = EventListViewController()
    let eventListPresenter = EventListPresenter(view: eventListVc)
    eventListVc.output = eventListPresenter
    return eventListVc
  }
  
  func makeEventMapOutput() -> EventMapView {
    return EventsMapViewController.controllerFromStoryboard(.map)
  }
  
  func makeEventDetailOutput(eventId: EventId) -> EventDetailsView {
    let vc = EventViewController()
    vc.hidesBottomBarWhenPushed = true
    let presenter = EventPresenter(view: vc, eventId: eventId)
    vc.output = presenter
    return vc
  }
  
  func makeCreateEventOutput() -> CreateEventView {
    return CreateEventViewController.controllerFromStoryboard(.create)
  }
  
  func makeFavouritesOutput() -> FavouritesView {
    return FavouritesTableViewController.controllerFromStoryboard(.favourites)
  }
  
  func makeSignInOutput() -> (SignInView, SignInModuleOutput) {
    let vc = SignInViewController.controllerFromStoryboard(.auth)
    let presenter = SignInPresenter(view: vc)
    vc.output = presenter
    return (vc, presenter)
  }
  
  func makeSettingsOutput() -> SettingsRootView {
    return SettingsTableViewController.controllerFromStoryboard(.settings)
  }
  
  func makeEditUserProfileOutput() -> UserInfoView {
    let vc = UserProfileTableViewController.controllerFromStoryboard(.settings)
    return vc
  }
}
