//
//  CommentCell.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 17.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import UIKit
import Kingfisher

class CommentCell: UITableViewCell {

  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var createdLabel: UILabel!
  @IBOutlet weak var likeButton: UIButton!
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var quoteView: UIView!
  @IBOutlet weak var quoteCommentUserName: UILabel!
  @IBOutlet weak var quoteMessage: UILabel!
  
  private var commentRendered = false
  
  var comment: (Comment, Comment?)! {
    didSet {
      renderUI()
    }
  }
  
  
  private func renderUI() {
    
    if self.comment.0.message == "ыч" {
      print (self.comment.0)
      print (self.comment.1)
    }
    
    quoteView.isHidden = self.comment.1 == nil
    
    if let quote = self.comment.1 {
      quoteCommentUserName.text = quote.userName ?? "Без имени"
      quoteMessage.text = quote.message
    }
    
    let comment = self.comment.0
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


  override func awakeFromNib() {
    super.awakeFromNib()
    avatarImageView?.layer.masksToBounds = true
    avatarImageView?.layer.cornerRadius = avatarImageView!.frame.height / 2
  }
  
}
