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

class UserProfileTableViewController: UITableViewController {
  
  
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var aboutTextField: UITextField!
  
  let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
  
  var viewModelRendered = true
  
  var viewModel: UserProfileViewModel! {
    didSet {
      viewModelRendered = false
      view.layoutSubviews()
    }
  }
  
  
  @objc private func donePressed() {
    
  }
  
  
  private func renderUI() {
    
    guard let viewModel = viewModel else { return }
    
    if let url = viewModel.avatarURL {
      avatarImageView.kf.setImage(with: URL(string: url))
    }
    
    usernameTextField.text = viewModel.userName
    aboutTextField.text = viewModel.about
    [usernameTextField, aboutTextField, avatarImageView].forEach { $0.isUserInteractionEnabled = viewModel.canEditProfile }
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
  }
  
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    store.subscribe(self)
  }
  
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    store.unsubscribe(self)
  }
  
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    if !viewModelRendered {
      renderUI()
      viewModelRendered = true
    }
  }
  
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath.section {
    case 1: viewModel.didTapLogout?()
    default: break
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
}


extension UserProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
 
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    let image = info[UIImagePickerControllerOriginalImage] as? UIImage
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
    let cropedSize = CGSize(width: avatarImageView.frame.width * UIScreen.main.scale, height: avatarImageView.frame.height * UIScreen.main.scale)
    let sendingImage = croppedImage.kf.resize(to: cropedSize, for: .aspectFit)
    if let imageData = sendingImage.kf.pngRepresentation() {
      avatarImageView.image = sendingImage
      viewModel.didSelectAvatar?(imageData)
    }
    controller.dismiss(animated: true)
  }
  
  func imageCropViewController(_ controller: RSKImageCropViewController, willCropImage originalImage: UIImage) {
    print (originalImage)
  }
}


extension UserProfileTableViewController: StoreSubscriber {
  
  func newState(state: AppState) {
    viewModel = UserProfileViewModel(state: state)
  }
  
}
