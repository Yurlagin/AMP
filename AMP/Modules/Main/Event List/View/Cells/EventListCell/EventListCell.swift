//
//  EventListCell.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 11/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import UIKit
import Kingfisher
import ReSwift
import CoreLocation
import TableKit

class EventListCell: UITableViewCell {
  
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var createdLabel: UILabel!
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var likesButton: UIButton!
  @IBOutlet weak var dislikesButton: UIButton!
  @IBOutlet weak var commentsButton: UIButton!
  @IBOutlet weak var fromMeLabel: UILabel!

  @IBAction func likePressed(_ sender: UIButton) {
    props?.didTapLike?(props!.event.id)
  }
  
  @IBAction func dislikePressed(_ sender: UIButton) {
    props?.didTapDislike?(props!.event.id)
  }
  
  @IBAction func commentPressed(_ sender: UIButton) {
    props?.commentPressed?()
  }
  
  static var estimatedHeight: CGFloat? {
    return 138
  }
  
  private var props: Props! {
    didSet {
      renderUI()
    }
  }
  
  private func renderUI() {
    let event = props.event
    
    if let userLocation = props.currentUserLocation {
      let eventLocation = CLLocation(latitude: event.latitude, longitude: event.longitude)
      let distance = eventLocation.distance(from: userLocation) / 1000
      fromMeLabel.text = String(format: "%.1f км.", arguments: [distance])
    } else {
      fromMeLabel.text = "???"
    }
    
    userNameLabel.text = event.userName ?? " "
    avatarImageView.kf.setImage(with: URL(string: event.avatarUrl ?? ""))
    addressLabel.text = event.address
    createdLabel.text = event.created.shortDayTimeString
    messageLabel.text = event.message?.stringByTrimingWhitespace()
    
    likesButton.tintColor = UIColor(red: 1, green: 0, blue: 0, alpha: event.like ? 1.0 : 0.35)
    dislikesButton.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: event.dislike ? 1.0 : 0.35)
    
    likesButton.setTitle(String(event.likes), for: .normal)
    dislikesButton.setTitle(String(event.dislikes), for: .normal)
    
    commentsButton.setTitle(String(event.commentsCount), for: .normal)
  }
  
  override func prepareForReuse() {
    fromMeLabel.text = nil
    
    userNameLabel.text = nil
    avatarImageView.image = nil
    addressLabel.text = nil
    createdLabel.text = nil
    messageLabel.text = nil
    
    likesButton.tintColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.35)
    dislikesButton.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.35)
    
    likesButton.setTitle(nil, for: .normal)
    dislikesButton.setTitle(nil, for: .normal)
    
    commentsButton.setTitle(nil, for: .normal)
    super.prepareForReuse()
  }
  
}

extension EventListCell {
  struct Props {
    var event: Event
    var didTapLike: ((_ eventId: EventId) -> Void)?
    var didTapDislike: ((_ eventId: EventId) -> Void)?
    var commentPressed: (()->())?
    var currentUserLocation: CLLocation?
  }
}

extension EventListCell: ConfigurableCell {
  
  func configure(with props: Props) {
    self.props = props
  }
  
}
