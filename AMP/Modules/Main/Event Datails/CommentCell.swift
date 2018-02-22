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
  
  @IBAction func likePressed(_ sender: UIButton) {
    // TODO: like handling
  }
  
  private var commentRendered = false
  
  var comment: Comment! {
    didSet {
      render(comment)
    }
  }
  
  
  private func render(_ comment: Comment) {
    avatarImageView.kf.setImage(with: URL(string: comment.avatarURL ?? ""))
    createdLabel.text = comment.created.shortDayTimeString
    
    if comment.likes > 0 {
      createdLabel.text! += " | Отметок нравится: \(comment.likes)"
    }

    likeButton.tintColor = UIColor(red: 1, green: 0, blue: 0, alpha: comment.like ? 1.0 : 0.35)
    
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
  }
}
