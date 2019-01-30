//
//  CommentsSectionHeaderView.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 20/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import UIKit

class CommentsSectionHeaderView: UIView {

  @IBOutlet weak var loadingMoreView: UIStackView!
  @IBOutlet weak var loadMoreButton: UIButton!

  enum Props {
    case none
    case loadingMore
    case moreButton(onTap: () -> Void)
  }
  
  var props: Props? {
    didSet {
      renderUI()
    }
  }
  
  private func renderUI() {
    let state = props ?? .none
    loadingMoreView?.isHidden = !state.isLoadingMore
    loadMoreButton?.isHidden = !state.isShowMoreButton
  }
  
  @IBAction func onLoadMore(_ sender: UIButton) {
    props?.onTap?()
  }
  
}

extension CommentsSectionHeaderView.Props {
  var isLoadingMore: Bool {
    if case .loadingMore = self {
      return true
    } else {
      return false
    }
  }
  
  var onTap: (() -> Void)? {
    if case .moreButton(let onTap) = self {
      return onTap
    } else {
      return nil
    }
  }
  
  var isShowMoreButton:  Bool {
    return onTap != nil
  }
}

