//
//  EventListTableViewCell.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 05.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import UIKit
import Kingfisher
import ReSwift
import CoreLocation

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
  
  @IBAction func likePressed(_ sender: UIButton) {
    didTapLike?(event.id)
  }
  
  @IBAction func dislikePressed(_ sender: UIButton) {
    didTapDislike?(event.id)
  }
  
  @IBAction func commentPressed(_ sender: UIButton) {
    commentPressed?()
  }
  
  var didTapLike: ((_ eventId: Int)->())?
  var didTapDislike: ((_ eventId: Int)->())?
  var commentPressed: (()->())?
  
  private var event: Event!
  
  func renderUI(event: Event) {
    
    self.event = event
    userNameLabel.text = event.userName ?? " "
    avatarImageView.kf.setImage(with: URL(string: event.avatarUrl ?? ""))
    addressLabel.text = event.address
    createdLabel.text = event.created.shortDayTimeString
    messageTextView.text = event.message?.stringByTrimingWhitespace()

    likesButton.tintColor = UIColor(red: 1, green: 0, blue: 0, alpha: event.like ? 1.0 : 0.35)
    dislikesButton.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: event.dislike ? 1.0 : 0.35)
    
    likesButton.setTitle(String(event.likes), for: .normal)
    dislikesButton.setTitle(String(event.dislikes), for: .normal)
    commentsButton.setTitle(String(event.commentsCount), for: .normal)
  }
  
}

extension EventListTableViewCell: StoreSubscriber {
  
  func newState(state: LocationState) {
    guard let userLocation = state.location else { return }
    let eventLocation = CLLocation(latitude: event.latitude, longitude: event.longitude)
    let distance = eventLocation.distance(from: userLocation) / 1000
    fromMeLabel.text = String(format: "%.1f км.", arguments: [distance])
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
