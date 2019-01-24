//
//  EventDetailsCell.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 14/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import UIKit
import TableKit
import Kingfisher
import DifferenceKit

class EventDetailsCell: UITableViewCell, ConfigurableCell {
  
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
  
  @IBAction func onLike(_ sender: UIButton) {
    props?.onLike?()
  }
  @IBAction func onDislike(_ sender: UIButton) {
    props?.onDislike?()
  }
  @IBAction func onComment(_ sender: UIButton) {
    props?.onComment?()
  }

  private var didLayout = false
  private var props: Props!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    selectionStyle = .none
  }

  func configure(with props: Props) {
    self.props = props
    let event = props.event
    userNameLabel.text = event.userName
    avatarImageView.kf.setImage(with: URL(string: event.avatarUrl ?? ""))
    addressLabel.text = event.address
    createdLabel.text = event.created.shortDayTimeString
    fromMeLabel.text = props.distance
    messageTextView.text = event.message?.stringByTrimingWhitespace()
    likesButton.tintColor = UIColor(red: 1, green: 0, blue: 0, alpha: event.like ? 1.0 : 0.35)
    dislikesButton.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: event.dislike ? 1.0 : 0.35)
    
    likesButton.setTitle(String(event.likes), for: .normal)
    dislikesButton.setTitle(String(event.dislikes), for: .normal)
    commentsButton.setTitle(String(event.commentsCount), for: .normal)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    if !didLayout, let props = props {
      didLayout = true
      mapImageView.kf.setImage(with: props.getMapURLByFrame(width: mapImageView.frame.size.width,
                                                            height: mapImageView.frame.size.height))
    }
  }
}

extension EventDetailsCell {
  struct Props {
    private let mapBaseURL = "https://usefulness.club/amp/staticmap.php?zoom=15&"
    let event: Event
    let distance: String
    let onLike: (() -> Void)?
    let onDislike: (() -> Void)?
    let onComment: (() -> Void)?
    func getMapURLByFrame(width: CGFloat, height: CGFloat) -> URL? {
      return URL(string: mapBaseURL + "size=\(width)x\(height)&center=\(event.latitude),\(event.longitude)&markers=\(event.latitude),\(event.longitude)")
    }
  }
}

extension EventDetailsCell.Props: Differentiable {
  var differenceIdentifier: Int {
    return event.id
  }
  
  func isContentEqual(to source: EventDetailsCell.Props) -> Bool {
    return self.distance == source.distance && self.event.isContentEqual(to: source.event)
  }
}
