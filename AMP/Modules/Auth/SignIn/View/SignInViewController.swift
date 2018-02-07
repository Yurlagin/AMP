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

class SignInViewController: UIViewController, SignInView {
  
  let phoneNumberKit = PhoneNumberKit()
  
  private var viewModelRendered = false
  private var firstStart = true
  
  var viewModel: ViewModel! {
    didSet {
      viewModelRendered = false
      view.setNeedsLayout()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setCancelEditGesture()
    phoneTextField.delegate = self
    NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: .UIKeyboardWillHide, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: .UIKeyboardWillShow, object: nil)

  }
  
  private func setCancelEditGesture() {
    let cancelEditGesture = UITapGestureRecognizer(target: self, action: #selector(cancelEdit))
    cancelEditGesture.cancelsTouchesInView = false
    view.addGestureRecognizer(cancelEditGesture)
  }
  
  @objc
  private func cancelEdit() {
    view.endEditing(true)
  }
  
  @IBOutlet weak var phoneLabel: UILabel!
  @IBOutlet weak var phoneTextField: UITextField!
  @IBOutlet weak var smsLabel: UILabel!
  @IBOutlet weak var smsTextField: UITextField!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var enterAnonimouslyButton: UIButton!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!

  
  @IBAction func nextButtonTapped(_ sender: UIButton) {
    let phone = try! phoneNumberKit.parse(phoneTextField.text!)
    viewModel.phoneButtonTapped?("+" + String(phone.countryCode) + String(phone.nationalNumber), smsTextField.text!)
  }
    
  @IBAction func enterAnonimouslyTapped(_ sender: UIButton) {
    viewModel.anonimousButtonTapped?()
  }
  
  var hud: MBProgressHUD?
  
  var onComplete: (() -> ())?
    
  private func renderViewModel(animated: Bool) {
    
    guard !viewModel.isAuthComplete else {
      onComplete?(); return
    }
    
    if viewModel.showHud {
      if let hud = hud {
        hud.show(animated: true)
      } else {
        hud = MBProgressHUD.showAdded(to: view, animated: true)
      }
    } else if let hud = hud {
      hud.hide(animated: true)
    }
    
    phoneLabel.isEnabled = viewModel.phoneFormEnabled
    phoneTextField.isEnabled = viewModel.phoneFormEnabled
    smsLabel.isHidden = viewModel.smsFormHidden
    smsTextField.isHidden = viewModel.smsFormHidden
    smsLabel.isEnabled = viewModel.smsFormEnabled
    smsTextField.isEnabled = viewModel.smsFormEnabled
    
    if animated {
      UIView.animate(withDuration: 0.5) {
        self.stackView.layoutIfNeeded()
      }
    }
    
    if let alertData = viewModel.showAlert {
      showErrorAlert(title: alertData.title, description: alertData.text)
    }

  }
  
  private func showErrorAlert(title: String?, description: String?) {
    let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default))
    present(alert, animated: true)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    store.subscribe(self) { subcription in
      subcription.select { $0.authState }
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillAppear(animated)
    store.unsubscribe(self)
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    if viewModelRendered == false {
      renderViewModel(animated: !firstStart)
      viewModelRendered = true
      firstStart = false
    }
  }
  
  
  @objc
  private func adjustForKeyboard(notification: Notification) {
    let userInfo = notification.userInfo!
    let kbDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
    let finalKBFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    let isShowing = notification.name == Notification.Name.UIKeyboardWillShow
    scrollViewBottomConstraint.constant = isShowing ? finalKBFrame.height : 0
    UIView.animate(withDuration: kbDuration, animations: {
      self.view.layoutIfNeeded()
    }) { _ in
      if isShowing {
        for textView in [self.phoneTextField, self.smsTextField] {
          if textView!.isFirstResponder {
            self.scrollView.scrollRectToVisible(textView!.frame, animated: true)
            break
          }
        }
      }
    }
  }
  
}

extension SignInViewController: StoreSubscriber {
  
  func newState(state: AuthState) {
    viewModel = ViewModel(state: state)
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

