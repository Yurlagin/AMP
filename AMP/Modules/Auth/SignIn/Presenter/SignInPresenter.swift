//
//  SignInPresenter.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 04/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import Foundation
import ReSwift

class SignInPresenter: SignInModuleOutput {
  weak var view: SignInViewInput?
  var onComplete: (() -> Void)?

  init(view: SignInViewInput) {
    self.view = view
  }
}

extension SignInPresenter: StoreSubscriber {
    func newState(state: AuthState) {
      let props = SignInViewController.Props(state: state)
      guard !props.isAuthComplete else {
        onComplete?()
        return
      }
      view?.props = props
    }
}

extension SignInPresenter: SignInViewOutput {
  
  func onViewWillAppear() {
    store.subscribe(self) { subcription in
      subcription.select { $0.authState }
    }
  }
  
  func onViewDidDissapear() {
    store.unsubscribe(self)
  }
  
}
