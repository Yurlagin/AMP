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
        let kbDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
        let finalKBFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
          return nil
      }
      self.isShowing = notification.name == .UIKeyboardWillShow
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
      name: .UIKeyboardWillShow,
      object: nil
    )
    notificationCenter.addObserver(
      self,
      selector: #selector(adjustForKeyboard(notification:)),
      name: .UIKeyboardWillHide,
      object: nil
    )
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    notificationCenter.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    notificationCenter.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
  }
  
  @objc final private func adjustForKeyboard(notification: Notification) {
    if let kbParams = KeyboardParameters(notification: notification) {
      adjustForKeyboard(params: kbParams)
    }
  }
  
  func adjustForKeyboard(params: KeyboardParameters) { }
}


