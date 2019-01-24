//
//  SettingsTableViewController.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 28.01.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import UIKit
import ReSwift
import Kingfisher

class SettingsTableViewController: UITableViewController, BaseView {
  
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var aboutLabel: UILabel!

  var didTap: ((MenuItem)->())?
  
  enum MenuItem {
    case profile
    case logout
    case notifications
  }
  
  private var isViewModelRendered = false
  
  private var viewModel: SettingsViewModel? {
    didSet {
      isViewModelRendered = false
      view.setNeedsLayout()
    }
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.refreshControl?.beginRefreshing() 
    setApperarence()
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    store.subscribe(self)
  }
  
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    store.unsubscribe(self)
  }
  
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    if !isViewModelRendered {
      renderViewModel()
      isViewModelRendered = true
    }
  }
  
  
  private func setApperarence() {
    avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
    avatarImageView.layer.masksToBounds = true
  }
  
  
  private func renderViewModel() {
    if let viewModel = viewModel, let urlString = viewModel.avatarURL, let avatarUrl = URL(string: urlString) {
      avatarImageView.kf.setImage(with: avatarUrl)
    }
    userNameLabel.text = viewModel?.userName
    aboutLabel.text = viewModel?.about
  }
  
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
   
    
    let section = indexPath.section; let row = indexPath.row
    switch section {
    case 0:
      if row == 0 {
//        if viewModel.canEditProfile {
          didTap?(.profile)
//        }
      }
    case 1:
      if row == 0 {
        didTap?(.notifications)
      }
    default:
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }
  
}

extension SettingsTableViewController: StoreSubscriber  {

  func newState(state: AppState) {
    viewModel = SettingsViewModel(state: state)
  }
  
}


struct SettingsViewModel {
 
  let avatarURL: String?
  let userName: String?
  let about: String?
  
  init? (state: AppState) {
    guard let user = state.authState.loginStatus.userCredentials else { return nil }
    avatarURL = user.avaurl
    userName = user.name
    about = user.about    
  }
  
}

extension LoginStatus {
  
  private func getLoginData() -> (UserCredentials, LogoutStatus)? {
    guard case .loggedIn(let user, let logoutStatus) = self else { return nil }
    return (user, logoutStatus)
  }
  
  var userCredentials: UserCredentials? {
    return getLoginData()?.0
  }
  
  var logoutStatus: LogoutStatus? {
    return getLoginData()?.1
  }
  
}
