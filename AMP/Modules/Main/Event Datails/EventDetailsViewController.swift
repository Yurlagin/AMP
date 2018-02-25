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
import SlackTextViewController

class EventDetailsViewController: SLKTextViewController {
 
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
  @IBOutlet weak var bottomStackView: UIStackView!

//  @IBOutlet weak var tableView: UITableView!
  
//  @IBOutlet weak var textinputViewBottomConstraint: NSLayoutConstraint!
//  @IBOutlet weak var textView: UITextView!
//  @IBOutlet weak var textInputView: UIView!

  @IBOutlet weak var sendButton: UIButton!
  
  
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
  
  @IBAction func sendButtonPressed(_ sender: UIButton) {
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

  
  fileprivate func setInitialAppearance() {
    
//    textView.layer.cornerRadius = 4
//    textView.layer.masksToBounds = true
//    textView.layer.borderColor = UIColor.lightGray.cgColor
//    textView.layer.borderWidth = 0.5
//    textView.delegate = self
    
//    NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: .UIKeyboardWillHide, object: nil)
//    NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: .UIKeyboardWillShow, object: nil)

//    let cancelEditGesture = UITapGestureRecognizer(target: self, action: #selector(cancelEdit))
//    tableView!.addGestureRecognizer(cancelEditGesture)

  }
  
  
//  @objc private func cancelEdit() {
//    view.endEditing(true)
//  }
  

  func renderUI () {
    
    guard let viewModel = eventViewModel else { return }
    
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
    
    let mapSize = mapImageView.frame.size
    mapImageView.kf.setImage(with: eventViewModel.getMapURL(mapSize.width, mapSize.height))
    
    DispatchQueue.global(qos: .userInitiated).async {
      let changes = diff(old: self.comments, new: viewModel.comments)
      
      let insertionsSet = Set(changes.flatMap{$0.insert?.index})
      let deletionsSet = Set(changes.flatMap{$0.delete?.index})
      let reloadsSet = deletionsSet.intersection(insertionsSet)
      
      let insertions = Array(insertionsSet.filter{!reloadsSet.contains($0)}.map{IndexPath(row: $0, section: 0)})
      let deletions = Array(deletionsSet.filter{!reloadsSet.contains($0)}.map{IndexPath(row: $0, section: 0)})
      
      self.comments = viewModel.comments
      
      DispatchQueue.main.async {
        reloadsSet.forEach {
          if let cell = self.tableView!.cellForRow(at: IndexPath(row: $0, section: 0)) as? CommentCell {
            cell.comment = self.comments[$0]
          }
        }
        
        self.tableView!.beginUpdates()
        self.tableView!.deleteRows(at: deletions, with: .automatic)
        self.tableView!.insertRows(at: insertions, with: .automatic)
        self.tableView!.endUpdates()
        
        self.eventViewModelRendered = true

      }
      
    }
    
  }
  
  
  private func showActionsForComment(index: Int) {
    
    let actions = eventViewModel.getActionsForComment(index)
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
                                          self.tableView!.cellForRow(at: IndexPath(row: index, section: 0))?.setSelected(false, animated: true)} ))
    }
    actionsVC.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: { _ in
      self.tableView!.cellForRow(at: IndexPath(row: index, section: 0))?.setSelected(false, animated: true) }))
    present(actionsVC, animated: true, completion: nil)
  }
  
  
//  @objc private func adjustForKeyboard(notification: Notification) {
//    let userInfo = notification.userInfo!
//    let kbDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
//    let finalKBFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//    let isShowing = notification.name == Notification.Name.UIKeyboardWillShow
//    textinputViewBottomConstraint.constant = isShowing ? finalKBFrame.height : 0
//
//    let rectToShow: CGRect
//    if tableView.frame.height > tableView.contentSize.height {
//      rectToShow = CGRect(origin: CGPoint(x: 0, y: tableView.tableFooterView!.frame.origin.y - 1),
//                          size: CGSize(width: tableView.frame.width, height: 1))
//    } else {
//      let y = textInputView.convert(CGPoint(x: 0, y: textView.frame.origin.y - 1), to: tableView).y
//      rectToShow = CGRect(origin: CGPoint(x: 0, y: y - 1),
//                          size: CGSize(width: tableView.frame.width, height: 1))
//    }
//
//    UIView.animate(withDuration: kbDuration, animations:  {
//      self.view.layoutIfNeeded()
//
//    }) { _ in
//      if isShowing {
//        self.tableView.scrollRectToVisible(rectToShow, animated: true)
//      }
//    }
//  }
  
  override class func tableViewStyle(for decoder: NSCoder) -> UITableViewStyle {
    return .plain
  }

  
  override func viewDidLoad() {
    tableView!.estimatedRowHeight = 120
    tableView!.rowHeight = UITableViewAutomaticDimension
    tableView!.tableFooterView = UIView()
//    setInitialAppearance()
    
  }
  
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    if !eventViewModelRendered {
      renderUI()//(viewModel: eventViewModel)
    }
    
    if let headerView = tableView!.tableHeaderView {
      let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
      var headerFrame = headerView.frame
      
      if height != headerFrame.size.height {
        headerFrame.size.height = height
        headerView.frame = headerFrame
        tableView!.tableHeaderView = headerView
      }
    }
  }
  
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    store.subscribe(self)
  }
  
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    store.unsubscribe(self)
  }
  
  
  deinit {
    eventViewModel?.onDeinitScreen(screenId)
  }

  
  
  
}


extension EventDetailsViewController {
 
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

}


extension EventDetailsViewController {
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    showActionsForComment(index: indexPath.row)
  }
  
}


extension EventDetailsViewController: StoreSubscriber {
  
  func newState(state: AppState) {
    if let eventViewModel = EventViewModel(eventId: eventId, screenId: screenId, state: state) {
      self.eventViewModel = eventViewModel
    }
  }
  
}

//extension EventDetailsViewController: UITextViewDelegate {
//
//  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//    print (textView.intrinsicContentSize.height)
//    textView.isScrollEnabled = textView.frame.height > 100
//    if !textView.isScrollEnabled {
//      textView.frame.size.height = textView.intrinsicContentSize.height
//    }
//
//    return true
//  }

//  func textViewDidChange(_ textView: UITextView) {
//    print(textView.isScrollEnabled)
//  }
  
//}

