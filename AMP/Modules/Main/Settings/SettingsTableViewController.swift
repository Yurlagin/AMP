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

class SettingsTableViewController: UITableViewController, SettingsRootView {
  @IBOutlet private weak var avatarImageView: UIImageView!
  @IBOutlet private weak var userNameLabel: UILabel!
  @IBOutlet private weak var aboutLabel: UILabel!

  var onSelect: ((SettingsRootViewMenuItem) -> ())?
  
  private var props: Props? {
    didSet {
      renderUI()
    }
  }
  
  struct Props {
    let avatarURL: String?
    let userName: String?
    let about: String?
    let userId: Int
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    store.subscribe(self)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    store.unsubscribe(self)
  }
  
  private func setup() {
    avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
    avatarImageView.layer.masksToBounds = true
  }
  
  private func renderUI() {
    if let viewModel = props, let urlString = viewModel.avatarURL {
      let avatarUrl = URL(string: urlString)
      avatarImageView.kf.setImage(with: avatarUrl)
    }
    userNameLabel.text = {
        if let props = props {
            let userName = props.userName ?? "NoName"
            return userName + " (id: \(props.userId))"
        }
        return nil
    }()
    aboutLabel.text = props?.about
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let section = indexPath.section
    let row = indexPath.row
    switch section {
    case 0:
      if row == 0 {
          onSelect?(.profile)
      }
      
    case 1:
      if row == 0 {
        onSelect?(.notifications)
      }
      
    default:
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }
}

extension SettingsTableViewController: StoreSubscriber  {
  func newState(state: AppState) {
    props = Props(state: state)
  }
}

extension SettingsTableViewController.Props {
  init? (state: AppState) {
    guard let userInfo = state.settingsState.userInfo else { return nil }
    avatarURL = userInfo.avatarURL
    userName = userInfo.userName
    about = userInfo.about
    userId = userInfo.userId
  }
}
