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
  
  func renderUI(event: Event) {
    
    
    userNameLabel.text = event.userName
    avatarImageView.kf.setImage(with: URL(string: event.avatarUrl!))
    addressLabel.text = event.address
    createdLabel.text = event.created.shortDayTimeString
    messageTextView.text = event.message?.stringByTrimingWhitespace()
    likesButton.setTitle(String(event.likes), for: .normal)
    dislikesButton.setTitle(String(event.dislikes), for: .normal)
    dislikesButton.setTitle(String(event.commentsCount), for: .normal)
  }
  
}

extension Date {
  
  var beginOfDay: Date {
    return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
  }
  
  var shortDayTimeString: String {
    let now = Date()
    let dateFormatter = DateFormatter()
    
    guard now.timeIntervalSince(self) > 0 else {
      dateFormatter.dateStyle = .short
      return dateFormatter.string(from: self)
    }
    
    if now.beginOfDay == self.beginOfDay {
      dateFormatter.timeStyle = .short
    } else if now.timeIntervalSince(self) < 7 * 24 * 60 * 60 {
      dateFormatter.dateFormat = "E"
    } else {
      dateFormatter.dateStyle = .short
    }
    
    return dateFormatter.string(from: self)
  }
  
}
