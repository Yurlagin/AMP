//
//  CommentTableViewCell.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 14/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import UIKit
import TableKit
import Kingfisher
import DifferenceKit

class CommentTableViewCell: UITableViewCell, ConfigurableCell {

  @IBOutlet private weak var avatarImageView: UIImageView!
  @IBOutlet private weak var createdLabel: UILabel!
  @IBOutlet private weak var likeButton: UIButton!
  @IBOutlet private weak var messageLabel: UILabel!
  @IBOutlet private weak var userNameLabel: UILabel!
  @IBOutlet private weak var quoteView: UIView!
  @IBOutlet private weak var quoteCommentUserName: UILabel!
  @IBOutlet private weak var quoteMessage: UILabel!

  @IBAction private func onLike(_ sender: UIButton) {
  }
  
  func configure(with props: Props) {
    let comment = props.comment
    backgroundColor = props.isSolution ? .green : .white
    quoteView.isHidden = comment.quote == nil
    
    if let quote = comment.quote {
      quoteCommentUserName.text = quote.userName
      quoteMessage.text = quote.message
    }
    
    avatarImageView.kf.setImage(with: URL(string: comment.avatarURL ?? ""))
    createdLabel.text = comment.created.shortDayTimeString
    
    if comment.likes > 0 {
      createdLabel.text! += " | Нравится: \(comment.likes)"
    }
    
    likeButton.isHidden = !comment.like
    
    let userName = comment.userName ?? "Без имени"
    let message = comment.message ?? " "
    
    userNameLabel.text = userName
    messageLabel.text = message
  }
}

extension CommentTableViewCell {
  struct Props: Hashable {
    let comment: Comment
    let isSolution: Bool
  }
}

extension CommentTableViewCell.Props: Differentiable {
  var differenceIdentifier: CommentId {
    return comment.id
  }
}

extension Comment: Differentiable {
  var differenceIdentifier: CommentId {
    return id
  }
}
