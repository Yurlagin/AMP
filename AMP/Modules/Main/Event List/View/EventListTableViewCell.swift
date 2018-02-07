//
//  EventListTableViewCell.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 05.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import UIKit
import Kingfisher

class EventListTableViewCell: UITableViewCell {
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var createdLabel: UILabel!
  @IBOutlet weak var messageTextView: UITextView!
  @IBOutlet weak var likesButton: UIButton!
  @IBOutlet weak var dislikesButton: UIButton!
  @IBOutlet weak var commentsButton: UIButton!
  @IBOutlet weak var fromMeLabel: UILabel!
  @IBOutlet weak var mapImageView: UIImageView!
  
  @IBAction func likePressed(_ sender: UIButton) {
  }
  
  @IBAction func dislikePressed(_ sender: UIButton) {
  }
  
  @IBAction func commentPressed(_ sender: UIButton) {
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  
  func renderUI(event: Event) {
    
    userNameLabel.text = event.userName
    avatarImageView.kf.setImage(with: URL(string: event.avatarUrl!))
    addressLabel.text = event.address
    
    let dateFormatter = DateFormatter()
    if event.created.timeIntervalSinceNow > 24 * 60 * 60 {
      dateFormatter.dateStyle = .short
    } else {
      dateFormatter.timeStyle = .short
    }
    
    createdLabel.text = dateFormatter.string(from: event.created)
    messageTextView.text = event.message
    likesButton.setTitle(String(event.likes), for: .normal)
    dislikesButton.setTitle(String(event.dislikes), for: .normal)
    dislikesButton.setTitle(String(event.commentsCount), for: .normal)

  }
  
  
  
  
  
  
}
