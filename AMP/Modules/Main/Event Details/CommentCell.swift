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
  @IBOutlet weak var messageTextView: UITextView!
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
    
    quoteView.isHidden = self.comment.1 == nil
    
    if let quote = self.comment.1 {
      quoteCommentUserName.text = quote.userName
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
    let message = comment.message ?? ""
    
    let signedMessage = NSMutableAttributedString(string: userName + " " + message)
    signedMessage.addAttribute(.font, value: UIFont.preferredFont(forTextStyle: .subheadline), range: signedMessage.mutableString.range(of: signedMessage.string))
    let userNameRange =  signedMessage.mutableString.range(of: userName)
    signedMessage.addAttribute(.link, value: "UserProfile://", range: userNameRange)
    signedMessage.addAttribute(.font, value: UIFont.preferredFont(forTextStyle: .subheadline), range: userNameRange)
    messageTextView.attributedText = signedMessage   
  }


  override func awakeFromNib() {
    super.awakeFromNib()
    messageTextView.textContainerInset = .zero
    messageTextView.offset
    messageTextView.textContainer.lineFragmentPadding = .leastNonzeroMagnitude
    avatarImageView?.layer.masksToBounds = true
    avatarImageView?.layer.cornerRadius = avatarImageView!.frame.height / 2
  }
  
}
