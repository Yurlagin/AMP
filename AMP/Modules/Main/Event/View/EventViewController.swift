//
//  EventViewController.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 14/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import UIKit
import DifferenceKit
import TableKit
import CoreLocation

protocol EventViewInput: class {
  func renderProps(_ props: EventViewController.Props)
}

protocol EventViewOutput {
  func onViewDidLoad()
  func onViewWillAppear()
  func onViewDidDissapear()
}

class EventViewController: KeyboardAdjustableViewController, EventDetailsView {
  
  // MARK: - EventViewInput
  var output: EventViewOutput?
  
  private var tableView: UITableView!
  private lazy var tableAnimator = EventTableAnimator(
    tableView: self.tableView,
    onPressComment: self.onPressComment,
    onSelectComment: onSelectComment
  )
  private lazy var onPressComment: () -> Void = { [unowned self] in
    _ = self.commentInputView.becomeFirstResponder()
  }
  
  private lazy var onSelectComment: (CommentId) -> Void = { [unowned self] commentId in
    guard let comment = self.props?.event.commentBy(id: commentId) else { return }
    let likeDislikeAction = UIAlertAction(
      title: comment.like ? "Больше не нравится" : "Нравится",
      style: .default,
      handler: { [weak self] _ in
        self?.props?.onLikeComment(comment.id)
      }
    )
    let quoteAction = UIAlertAction(
      title: "Ответить",
      style: .default,
      handler: { [weak self] _ in
        self?.props?.onChangeCommentType(.answer(commentId))
        _ = self?.commentInputView.becomeFirstResponder()
      }
    )
    let resolveAction: UIAlertAction? = self.props?.event.solutionCommentId == nil
      ? UIAlertAction(
        title: "Отметить, как решение",
        style: .default,
        handler: { [weak self] _ in
          self?.props?.onChangeCommentType(.resolve(commentId))
          _ = self?.commentInputView.becomeFirstResponder()
        }
        )
      : nil
    let cancelAction = UIAlertAction(
      title: "Отмена",
      style: .cancel,
      handler: { _ in }
    )
    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    [likeDislikeAction, quoteAction, resolveAction, cancelAction].compactMap{$0}.forEach(actionSheet.addAction)
    self.present(actionSheet, animated: true)
  }
  
  private lazy var commentInputView = CommentInputView.nib()
  private var inputViewBottomConstraint: NSLayoutConstraint!
  
  private var props: Props? {
    didSet {
      tableAnimator.props = props
      if let props = props {
        commentInputView.props = CommentInputView.Props.init(
          quote: props.commentQuote,
          text: props.draftText,
          isBlocked: props.isInputViewBlocked,
          onClearQuote: { props.onChangeCommentType(.new) },
          onDraft: props.onDraftMessage,
          onSend: props.onSendComment
        )
        if let errorAlertData = props.errorAlert, presentedViewController == nil {
          showOkAlert(title: "Oops!", message: errorAlertData.text) {
            errorAlertData.onTap()
          }
        }
      }
    }
  }
  
  private func makeTableView() -> EventTableView {
    let tableView = EventTableView()
    tableView.tableFooterView = UIView()
    return tableView
  }
  
  private func setupInputView() {
    commentInputView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(commentInputView)
    var constraints = [NSLayoutConstraint]()
    if #available(iOS 11.0,*) {
      inputViewBottomConstraint = view.safeAreaLayoutGuide.bottomAnchor.constraint(
        equalTo: commentInputView.bottomAnchor)
      let bottom = UIView()
      bottom.backgroundColor = .white
      bottom.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(bottom)
      constraints.append(contentsOf: [
        bottom.widthAnchor.constraint(equalTo: view.widthAnchor),
        bottom.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        bottom.heightAnchor.constraint(equalToConstant: 40),
        bottom.topAnchor.constraint(equalTo: commentInputView.bottomAnchor),
        ])
    } else {
      inputViewBottomConstraint = view.bottomAnchor.constraint(equalTo: commentInputView.bottomAnchor)
    }
    constraints.append(contentsOf: [
      inputViewBottomConstraint,
      commentInputView.widthAnchor.constraint(equalTo: view.widthAnchor),
      commentInputView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
      ])
    NSLayoutConstraint.activate(constraints)
  }
  
  override func loadView() {
    let view = UIView()
    let tableView = makeTableView()
    tableView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(tableView)
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      view.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
      view.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
      ])
    self.view = view
    self.tableView = tableView
    setupInputView()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "Детали"
    if #available(iOS 11.0, *) {
      navigationItem.largeTitleDisplayMode = .automatic
    }
    output?.onViewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    output?.onViewWillAppear()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    output?.onViewDidLoad()
  }
  
  override func adjustForKeyboard(params: KeyboardAdjustableViewController.KeyboardParameters) {
    if #available(iOS 11.0, *) {
      self.tableView.contentInset.bottom = params.finalFrame.height + self.tableView.safeAreaInsets.bottom
    } else {
      self.tableView.contentInset.bottom = params.finalFrame.height
    }
    inputViewBottomConstraint.constant = params.isShowing ? params.finalFrame.height : 0
    tableView.contentInset.bottom = commentInputView.frame.size.height +
      (params.isShowing ? params.finalFrame.height : 0)
    UIView.animate(withDuration: params.animationDuration) {
      self.view.layoutIfNeeded()
    }
  }
}

extension EventViewController: EventViewInput {
  func renderProps(_ props: EventViewController.Props) {
    self.props = props
  }
}

extension Event {
  func commentBy(id: CommentId) -> Comment? {
    return comments?.first{$0.id == id}
  }
}
