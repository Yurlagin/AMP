//
//  EventDetailsTableViewController.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 15.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import UIKit
import ReSwift
import DeepDiff

class EventDetailsTableViewController: UITableViewController {
 
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var mapImageView: UIImageView!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var createdLabel: UILabel!
  @IBOutlet weak var messageTextView: UITextView!
  @IBOutlet weak var likesButton: UIButton!
  @IBOutlet weak var dislikesButton: UIButton!
  @IBOutlet weak var commentsButton: UIButton!
  @IBOutlet weak var fromMeLabel: UILabel!
  @IBOutlet weak var loadMoreButton: UIButton!
  @IBOutlet weak var loadingStackView: UIStackView!
  
  @IBAction func likePressed(_ sender: UIButton) {
    eventViewModel.didTapLike()
  }
  
  @IBAction func dislikePressed(_ sender: UIButton) {
    eventViewModel.didTapDislike()
  }
  
  @IBAction func commentPressed(_ sender: UIButton) {
  }
  
  @IBAction func loadMorePressed(_ sender: UIButton) {
    eventViewModel.didTapLoadMore()
  }
  
  var eventId: Int!
  var screenId: ScreenId!
  
  private var comments = [Comment]()
  
  private var eventViewModelRendered = false
  private var isFirstViewModelReceived = false
  
  fileprivate var eventViewModel: EventViewModel! {
    didSet {
      eventViewModelRendered = false
      view.setNeedsLayout()
    }
  }
  
  var didTapLike: ((_ eventId: Int)->())?
  var didTapDislike: ((_ eventId: Int)->())?
  
  
  // TODO: make it work
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return [.portrait] }
  override var shouldAutorotate: Bool { return false }

  
  override func viewDidLoad() {
    tableView.estimatedRowHeight = 120
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.tableFooterView = UIView()
  }
  
  
  func render(viewModel: EventViewModel) {
    
    let changes = diff(old: comments, new: viewModel.comments)
    comments = viewModel.comments
    tableView.reload(changes: changes) { (_) in }
    
    let event = viewModel.event
    userNameLabel.text = event.userName
    avatarImageView.kf.setImage(with: URL(string: event.avatarUrl!))
    addressLabel.text = event.address
    createdLabel.text = event.created.shortDayTimeString
    fromMeLabel.text = viewModel.distance
    
    messageTextView.text = event.message?.stringByTrimingWhitespace()
    
    likesButton.tintColor = UIColor(red: 1, green: 0, blue: 0, alpha: event.like ? 1.0 : 0.35)
    dislikesButton.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: event.dislike ? 1.0 : 0.35)
    
    likesButton.setTitle(String(event.likes), for: .normal)
    dislikesButton.setTitle(String(event.dislikes), for: .normal)
    commentsButton.setTitle(String(event.commentsCount), for: .normal)
    
    switch viewModel.loadMoreButtonState {
    case .none:
      loadMoreButton.isHidden = true
      loadingStackView.isHidden = true
    case .showButton, .showButtonWithError: //TODO: Add error alert..
      loadMoreButton.isHidden = false
      loadingStackView.isHidden = true
    case .showLoading:
      loadMoreButton.isHidden = true
      loadingStackView.isHidden = false
    }
    
  }
  
  
  private func showActionsForComment(index: Int) {
    
    let actions =  eventViewModel.getActionsForComment(index)
    let actionsVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    actions.forEach { action in
      let buttonTitle: String
      switch action {
      case .like: buttonTitle = "Мне нравится"
      case .dislike: buttonTitle = "Больше не нравится"
      case .answer: buttonTitle = "Ответить"
      case .resolve: buttonTitle = "Отметить, как решение"
      }
      actionsVC.addAction(UIAlertAction(title: buttonTitle,
                                        style: .default,
                                        handler: { _ in
                                          self.eventViewModel.didTapCommentAction(action, index)
                                          self.tableView.cellForRow(at: IndexPath(row: index, section: 0))?.setSelected(false, animated: true)} ))
    }
    actionsVC.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: { _ in
      self.tableView.cellForRow(at: IndexPath(row: index, section: 0))?.setSelected(false, animated: true) }))
    present(actionsVC, animated: true, completion: nil)
  }
  
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    if !eventViewModelRendered {
      render(viewModel: eventViewModel)
      eventViewModelRendered = true
    }
    
    if let headerView = tableView.tableHeaderView {
      let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
      var headerFrame = headerView.frame
      
      if height != headerFrame.size.height {
        headerFrame.size.height = height
        headerView.frame = headerFrame
        tableView.tableHeaderView = headerView
      }
    }
  }
  
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    let mapSize = mapImageView.frame.size
    mapImageView.kf.setImage(with: eventViewModel.getMapURL(mapSize.width, mapSize.height))
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    store.subscribe(self)
  }
  
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    store.unsubscribe(self)
  }
  
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return comments.count
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
    cell.comment = comments[indexPath.row]
    return cell
  }
  
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    showActionsForComment(index: indexPath.row)
  }
  
  deinit {
    eventViewModel?.onDeinitScreen(screenId)
  }

  
}


extension EventDetailsTableViewController: StoreSubscriber {
  
  func newState(state: AppState) {
    if let eventViewModel = EventViewModel(eventId: eventId, screenId: screenId, state: state) {
      self.eventViewModel = eventViewModel
    }
  }
  
}
