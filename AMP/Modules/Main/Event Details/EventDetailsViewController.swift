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
import MBProgressHUD

class EventDetailsViewController: UIViewController, EventDetailsView {
  
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
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var textInputSeparatorView: NSLayoutConstraint!
  
  @IBOutlet weak var textInputViewBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var textInputView: UIView!
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var placeHolderLabel: UILabel!
  @IBOutlet weak var sendButton: UIButton!
  
  @IBOutlet weak var quoteView: UIView!
  @IBOutlet weak var quoteUserName: UILabel!
  @IBOutlet weak var quoteTextLabel: UILabel!
  
  
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
    eventViewModel.didTapSendComment(textView.text)
  }
  
  @IBAction func cleanQouteTapped(_ sender: UIButton) {
    quoteUserName.text = nil
    quoteTextLabel.text = nil
    showQuoteView(false)
    eventViewModel.didTapClearQoute()
  }
  
  var eventId: Int!
  var screenId: ScreenId!

  var rowHeights = [Int: CGFloat]()
  
  private var progressHud: MBProgressHUD?
  
  private var comments = [Comment]()
  private var replyedComments = [CommentId: Comment]()
  
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
    
    textView.layer.cornerRadius = 4
    textView.layer.masksToBounds = true
    textView.layer.borderColor = UIColor.lightGray.cgColor
    textView.layer.borderWidth = 0.5
    textView.delegate = self
    
    NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: .UIKeyboardWillHide, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: .UIKeyboardWillShow, object: nil)
    
    let cancelEditGesture = UITapGestureRecognizer(target: self, action: #selector(cancelEdit))
    cancelEditGesture.cancelsTouchesInView = false
    tableView.addGestureRecognizer(cancelEditGesture)
    
    tableView.tableFooterView = UIView()
    
    textInputSeparatorView.constant = 0.3
    
    showQuoteView(false, animated: false)
  }
  
  
  @objc private func cancelEdit() {
    view.endEditing(true)
  }
  
  
  func renderUI() {
    
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
    
    if viewModel.shouldDisplayHUD {
      if progressHud == nil {
        progressHud = MBProgressHUD.showAdded(to: view, animated: true)
        progressHud!.removeFromSuperViewOnHide = true
      }
    } else {
      if let _ = progressHud {
        progressHud!.hide(animated: true)
        progressHud = nil
      }
    }
    
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
    
    let changes = diff(old: self.comments, new: viewModel.comments)
    
    let insertionsSet = Set(changes.flatMap{$0.insert?.index})
    let deletionsSet = Set(changes.flatMap{$0.delete?.index})
    let reloadsSet = deletionsSet.intersection(insertionsSet)
    
    let insertions = Array(insertionsSet.filter{!reloadsSet.contains($0)}.map{IndexPath(row: $0, section: 0)})
    let deletions = Array(deletionsSet.filter{!reloadsSet.contains($0)}.map{IndexPath(row: $0, section: 0)})
    
    comments = viewModel.comments
    replyedComments = viewModel.replyedComments
    
    tableView.beginUpdates()
    tableView.deleteRows(at: deletions, with: .automatic)
    tableView.insertRows(at: insertions, with: .automatic)
    tableView.reloadRows(at: Array(reloadsSet.map{IndexPath(row: $0, section: 0)}), with: .automatic)
    tableView.endUpdates()
    
    if viewModel.shouldShowPostedComment(), !viewModel.comments.isEmpty {
      textView.text = ""
      showQuoteView(false)
      textViewDidChange(self.textView)
      markSolutionComment()
      tableView.scrollToRow(at: IndexPath(row: viewModel.comments.count - 1, section: 0), at: .bottom, animated: true)
    }
    
    eventViewModelRendered = true
  }
  
  
  private func markSolutionComment() {
    if let solutionCommentId = eventViewModel.event.solutionCommentId,
      let postedCommentReplyId = comments.last?.replyToId,
      solutionCommentId == postedCommentReplyId,
      let index = comments.index(where: { $0.id == solutionCommentId }) {
      tableView.beginUpdates()
      tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
      tableView.endUpdates()
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
      actionsVC.addAction(UIAlertAction(
        title: buttonTitle,
        style: .default,
        handler: { _ in
          
          func fillQouteView() {
            let comment = self.comments[index]
            self.quoteUserName.text = comment.userName ?? "Без имени"
            self.quoteTextLabel.text = comment.message ?? ""
            self.showQuoteView(true)
            self.textView.becomeFirstResponder()
          }
          
          if case .answer = action {
            fillQouteView()
          } else if case .resolve = action {
            fillQouteView()
          }
          
          self.eventViewModel.didTapCommentAction(action, index)
          self.tableView.deselectRow(at: IndexPath(row: index, section: 0), animated: true)} ))
    }
    
    actionsVC.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: { _ in
      self.tableView.deselectRow(at: IndexPath(row: index, section: 0), animated: true) }))
    
    present(actionsVC, animated: true, completion: nil)
  }
  
  
  private func showQuoteView(_ show: Bool, animated: Bool = true) {
    quoteView.isHidden = !show
    UIView.animate(withDuration: animated ? 0.25 : 0) {
      self.view.layoutIfNeeded()
    }
  }
  
  
  @objc private func adjustForKeyboard(notification: Notification) {
    let userInfo = notification.userInfo!
    let kbDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
    let finalKBFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    let isShowing = notification.name == Notification.Name.UIKeyboardWillShow
    textInputViewBottomConstraint.constant = isShowing ? finalKBFrame.height : 0
    
    let contentRect = CGRect(origin: .zero, size: tableView.contentSize)
    let overlayRect = view.convert(finalKBFrame.union(textInputView.frame), to: tableView)
    let intersectionRect = contentRect.intersection(overlayRect)
    let visibleContentHeight = tableView.frame.height - intersectionRect.height
    let hidingRect = CGRect(origin: intersectionRect.origin, size: CGSize(width: intersectionRect.width, height: min(intersectionRect.height, visibleContentHeight)))
    
    UIView.animate(withDuration: kbDuration) {
      self.view.layoutIfNeeded()

      if isShowing, hidingRect.height > 0 {
        self.tableView.scrollRectToVisible(hidingRect, animated: false)
      } else {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
      }
    }
  }
  
  
  override func viewDidLoad() {
    tableView.estimatedRowHeight = 120
    tableView.rowHeight = UITableViewAutomaticDimension
    setInitialAppearance()
  }
  
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    if !eventViewModelRendered {
      renderUI()
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


extension EventDetailsViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return comments.count
  }
  
  private func replayedCommentFor(_ comment: Comment) -> Comment? {
    let replyedComment: Comment?
    if let replyId = comment.replyToId  {
      replyedComment = replyedComments[replyId]
    } else {
      replyedComment = nil
    }
    return replyedComment
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
    let comment = comments[indexPath.row]
    cell.viewModel = (comment, replayedCommentFor(comment))
    cell.backgroundColor = eventViewModel.event.solutionCommentId == comment.id ? UIColor.hexColor(rgb: 0xCFFFBA) : .white
    return cell
  }
  
}


extension EventDetailsViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    showActionsForComment(index: indexPath.row)
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if rowHeights[indexPath.row] == nil {
      rowHeights[indexPath.row] = cell.frame.height
    }
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return rowHeights[indexPath.row] ?? 120
  }
  
}


extension EventDetailsViewController: StoreSubscriber {
  
  func newState(state: AppState) {
    if let eventViewModel = EventViewModel(eventId: eventId, screenId: screenId, state: state) {
      self.eventViewModel = eventViewModel
    }
  }
  
}


extension EventDetailsViewController: UITextViewDelegate {
  
  
  func textViewDidChange(_ textView: UITextView) {
    
    let textViewHeight = max(min(textView.contentSize.height, 120.0), 34.0)
    textViewHeightConstraint.constant = textViewHeight
    UIView.animate(withDuration: 0.25) {
      self.view.layoutIfNeeded()
    }
    
    let isTextEmpty = textView.text.isEmpty
    placeHolderLabel.isHidden = !isTextEmpty
    sendButton.isEnabled = !isTextEmpty
  }
  
  
}

