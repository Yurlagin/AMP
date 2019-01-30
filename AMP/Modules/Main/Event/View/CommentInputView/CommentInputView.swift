//
//  CommentInputView.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 15/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import UIKit

class CommentInputView: UIView {
  
  @IBOutlet private weak var quoteView: UIView!
  @IBOutlet private weak var quoteUserNameLabel: UILabel!
  @IBOutlet private weak var quoteTextLabel: UILabel!
  @IBOutlet private weak var quoteCancelButton: UIButton!
  @IBOutlet private weak var commentTextView: UITextView!
  @IBOutlet private weak var commentPaceholderLabel: UILabel!
  @IBOutlet private weak var sendButton: UIButton!
  @IBOutlet private weak var textViewHeightConstraint: NSLayoutConstraint!
  
  @IBAction private func onCancelQuote(_ sender: UIButton){
    props?.onClearQuote()
  }
  
  @IBAction private func onSend(_ sender: UIButton) {
    props?.onSend()
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    commentTextView.delegate = self
    renderUI()
  }
  
  override func becomeFirstResponder() -> Bool {
    super.becomeFirstResponder()
    return commentTextView.becomeFirstResponder()
  }
  
  var props: Props? {
    didSet {
      renderUI()
    }
  }
  
  struct Props {
    let quote: CommentQuote?
    let text: String
    let isBlocked: Bool
    let onClearQuote: () -> ()
    let onDraft: (String) -> ()
    let onSend: () -> ()
  }
  
  private func renderUI() {
    guard let props = props else { return }
    let isTextEmpty = props.text.isEmpty
    sendButton.isEnabled = !isTextEmpty && !props.isBlocked
    commentTextView.text = props.text
    commentTextView.isEditable = !props.isBlocked
    quoteView.isHidden = props.quote == nil
    quoteUserNameLabel.text = props.quote?.userName
    quoteTextLabel.text = props.quote?.message
    commentPaceholderLabel.isHidden = !isTextEmpty
    adjustTextViewHeight()
  }
  
  private func adjustTextViewHeight() {
    let textViewHeight = max(min(commentTextView.contentSize.height, 120.0), 34.0)
    textViewHeightConstraint.constant = textViewHeight
    UIView.animate(withDuration: 0.25) {
      self.layoutIfNeeded()
    }
  }
}

extension CommentInputView: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    props?.onDraft(textView.text ?? "")
  }
}
