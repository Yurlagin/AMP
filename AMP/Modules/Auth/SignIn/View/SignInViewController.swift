//
//  SignInViewController.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 20.01.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import UIKit
import ReSwift
import PhoneNumberKit
import MBProgressHUD

protocol SignInViewInput: class {
  var props: SignInViewController.Props! { get set }
}

protocol SignInViewOutput: class {
  func onViewWillAppear()
  func onViewDidDissapear()
}

class SignInViewController: UIViewController, SignInViewInput {
  
  private let phoneNumberKit = PhoneNumberKit()
  private let notificationCenter = NotificationCenter.default

  var output: SignInViewOutput!
  
  private var isPropsRendered = false
  private var isFirstStart = true
  
  private var hud: MBProgressHUD?
  
  @IBOutlet private weak var phoneLabel: UILabel!
  @IBOutlet private weak var phoneTextField: UITextField!
  @IBOutlet private weak var smsLabel: UILabel!
  @IBOutlet private weak var smsTextField: UITextField!
  @IBOutlet private weak var nextButton: UIButton!
  @IBOutlet private weak var stackView: UIStackView!
  @IBOutlet private weak var enterAnonymouslyButton: UIButton!
  @IBOutlet private weak var scrollView: UIScrollView!
  @IBOutlet private weak var scrollViewBottomConstraint: NSLayoutConstraint!
  
  @IBAction func nextButtonTapped(_ sender: UIButton) {
    guard let phone = try? phoneNumberKit.parse(phoneTextField.text ?? "") else {
      return
    }
    props.onSingInAttempt?("+" + String(phone.countryCode) + String(phone.nationalNumber), smsTextField.text!)
  }
  
  @IBAction func enterAnonymouslyTapped(_ sender: UIButton) {
    props.onAnonymousAttempt?()
  }

  var props: Props! {
    didSet {
      renderProps()
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    view.endEditing(true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    phoneTextField.delegate = self
  }
  
  private func renderProps() {
    
    if props.showHud {
      if let hud = hud {
        hud.show(animated: true)
      } else {
        hud = MBProgressHUD.showAdded(to: view, animated: true)
      }
    } else if let hud = hud {
      hud.hide(animated: true)
    }
    
    phoneLabel.isEnabled = props.phoneFormEnabled
    phoneTextField.isEnabled = props.phoneFormEnabled
    smsLabel.isHidden = props.smsFormHidden
    smsTextField.isHidden = props.smsFormHidden
    smsLabel.isEnabled = props.smsFormEnabled
    smsTextField.isEnabled = props.smsFormEnabled
    
    if let alertData = props.showAlertPrompt {
      showOkAlert(title: alertData.title, message: alertData.text)
    }
    
  }
    
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
    notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    output.onViewWillAppear()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    notificationCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    output.onViewDidDissapear()
  }
  
  @objc private func adjustForKeyboard(notification: Notification) {
    let userInfo = notification.userInfo!
    let kbDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
    let finalKBFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    let isShowing = notification.name == UIResponder.keyboardWillShowNotification
    scrollViewBottomConstraint.constant = isShowing ? finalKBFrame.height : 0
    UIView.animate(withDuration: kbDuration, animations: {
      self.view.layoutIfNeeded()
    }) { _ in
      if isShowing {
        for textView in [self.phoneTextField, self.smsTextField] {
          if textView?.isFirstResponder == true {
            self.scrollView.scrollRectToVisible(textView!.frame, animated: true)
            break
          }
        }
      }
    }
  }
}

extension SignInViewController: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
    let number = try? phoneNumberKit.parse(newString)
    nextButton.isEnabled = number != nil
    return true
  }
}

extension SignInViewController: SignInView { }
