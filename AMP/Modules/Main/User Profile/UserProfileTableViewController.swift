//
//  UserProfileTableViewController.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 11.03.2018.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import UIKit
import ReSwift
import MBProgressHUD
import Kingfisher
import RSKImageCropper

class UserProfileTableViewController: UITableViewController, UserInfoView {
  @IBOutlet private weak var avatarImageView: UIImageView!
  @IBOutlet private weak var usernameTextField: UITextField!
  @IBOutlet private weak var aboutTextField: UITextField!
  
  var onDone: (() -> Void)?

  private let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
  private var hud: MBProgressHUD?
  
  var props: Props? {
    didSet {
      if let props = props, state == nil { state = State(userInfo: props.userInfo) }
      renderUI()
      if let oldProps = oldValue { checkFlowCompletion(oldProps: oldProps) }
    }
  }
  
  private func checkFlowCompletion(oldProps: Props) {
    guard let props = props else { return }
    let isChangeRequestCompletedSuccessfuly = props.errorAlert == nil && oldProps.showHud
    if isChangeRequestCompletedSuccessfuly {
      onDone?()
    }
  }
  
  private struct State {
    var userInfo: UserInfo?
  }
  private var state: State? {
    didSet {
      renderUI()
    }
  }
  
  private var isDoneButtonEnabled: Bool {
    return state != nil
      && props?.userInfo != state?.userInfo
      && props?.canEditProfile == true
      && props?.showHud == false
  }
  
  @objc private func donePressed() {
    if let userInfo = state?.userInfo {
      props?.onSendUserInfo(userInfo)
    }
  }
  
  private func renderUI() {
    if props?.showHud == true {
      if hud == nil {
        hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.removeFromSuperViewOnHide = true
      }
    } else {
      hud?.hide(animated: true)
      hud = nil
    }
    
    doneButton.isEnabled = isDoneButtonEnabled
    navigationItem.rightBarButtonItem = props?.canEditProfile == true ? doneButton : nil
    [usernameTextField, aboutTextField, avatarImageView].forEach {
      $0?.isUserInteractionEnabled = props?.canEditProfile == true
    }
    if let (title, text) = props?.errorAlert {
      showOkAlert(title: title, message: text)
      props?.onShowError()
    }

    guard let state = state else { return }
    if let url = state.userInfo?.avatarURL {
      avatarImageView.kf.setImage(with: URL(string: url))
    }
    usernameTextField.text = state.userInfo?.userName
    aboutTextField.text = state.userInfo?.about
  }
  
  @objc private func showAvatarPicker() {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = .photoLibrary
    imagePicker.delegate = self
    present(imagePicker, animated: true)
  }
  
  fileprivate func showAvatarCropper(image: UIImage?) {
    guard let image = image else { return }
    let cropper = RSKImageCropViewController(image: image, cropMode: .circle)
    cropper.delegate = self
    present(cropper, animated: false)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let avatarTapGesture = UITapGestureRecognizer(target: self, action: #selector(showAvatarPicker))
    avatarImageView.addGestureRecognizer(avatarTapGesture)
    avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
    avatarImageView.layer.masksToBounds = true
    [usernameTextField, aboutTextField].forEach{$0?.delegate = self}
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    store.subscribe(self)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    store.unsubscribe(self)
  }
  
  deinit {
    props?.onLeaveScreen()
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath.section {
    case 1: props?.onLogout?()
    default: break
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

extension UserProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

    let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
    picker.dismiss(animated: false) { [weak self] in
      self?.showAvatarCropper(image: image)
    }
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true)
  }
}

extension UserProfileTableViewController: RSKImageCropViewControllerDelegate {
  func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
    controller.dismiss(animated: true)
  }
  
  func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
    let cropedSize = CGSize(
      width: avatarImageView.frame.width * UIScreen.main.scale,
      height: avatarImageView.frame.height * UIScreen.main.scale
    )
    let sendingImage = croppedImage.kf.resize(to: cropedSize, for: .aspectFit)
    if let imageData = sendingImage.kf.pngRepresentation() {
      avatarImageView.image = sendingImage
      props?.onSelectAvatar?(imageData)
    }
    controller.dismiss(animated: true)
  }
}

extension UserProfileTableViewController: StoreSubscriber {
  func newState(state: AppState) {
    props = Props(state: state)
  }
}

extension UserProfileTableViewController: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let finalString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
    switch textField {
    case aboutTextField: state?.userInfo?.about = finalString
    case usernameTextField: state?.userInfo?.userName = finalString
    default: break
    }
    
    return false
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    switch textField {
    case aboutTextField: state?.userInfo?.about = textField.text
    case usernameTextField: state?.userInfo?.userName = textField.text
    default: break
    }
  }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
