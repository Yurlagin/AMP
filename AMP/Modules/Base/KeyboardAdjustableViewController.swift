//
//  KeyboardAdjustableViewController.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 16/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import UIKit

class KeyboardAdjustableViewController: UIViewController {
  
  struct KeyboardParameters {
    let isShowing: Bool
    let animationDuration: TimeInterval
    let finalFrame: CGRect
    
    init?(notification: Notification) {
      guard let userInfo = notification.userInfo,
        let kbDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
        let finalKBFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
          return nil
      }
      self.isShowing = notification.name == UIResponder.keyboardWillShowNotification
      self.animationDuration = kbDuration
      self.finalFrame = finalKBFrame
    }
  }
  
  private let notificationCenter = NotificationCenter.default
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    notificationCenter.addObserver(
      self,
      selector: #selector(adjustForKeyboard(notification:)),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
    notificationCenter.addObserver(
      self,
      selector: #selector(adjustForKeyboard(notification:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    notificationCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  @objc final private func adjustForKeyboard(notification: Notification) {
    if let kbParams = KeyboardParameters(notification: notification) {
      adjustForKeyboard(params: kbParams)
    }
  }
  
  func adjustForKeyboard(params: KeyboardParameters) { }
}


