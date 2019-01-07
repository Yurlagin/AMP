//
//  AuthServiceError.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 06/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import Firebase
import Locksmith

enum AuthServiceError: Error {
  case captchaCheckFailed
  case invalidPhoneNumber
  case invalidVerificationCode
  case smsSessionExpired
  case noNetwork
  case ioError
  case other
  
  init (error: Error) {
    if let authErrorCode = AuthErrorCode(rawValue: (error as NSError).code) {
      switch authErrorCode {
      case .captchaCheckFailed: self = .captchaCheckFailed
      case .invalidPhoneNumber: self = .invalidPhoneNumber
      case .invalidVerificationCode: self = .invalidVerificationCode
      case .sessionExpired: self = .smsSessionExpired
      default: self = .other
      }
    } else if let apiError = error as? ApiError {
      if apiError == .noNetwork {
        self = .noNetwork
      } else {
        self = .other
      }
    } else if error is LocksmithError {
      self = .ioError
    } else {
      self = .other
      assertionFailure("AuthServiceError should be initialized from Firebase or Api Errors only")
    }
  }
}

extension AuthServiceError: CustomStringConvertible {
  
  var description: String {
    switch self {
    case .captchaCheckFailed: return "Captcha проверка не пройдена"
    case .invalidPhoneNumber: return "Введен некорректный номер"
    case .invalidVerificationCode: return "Неверный смс-код"
    case .smsSessionExpired: return "Смс-код устарел, пожалуйста запросите новый код"
    case .noNetwork: return "Невозможоно подключиться к серверу. Пожалуйста, попробуйте позже"
    case .ioError: return "Невозможно прочитать/записать данные авторизации"
    case .other: return "Что-то пошло не так... Пожалуйста, попробуйте еще раз"
    }
  }
  
  var localizedDescription: String {
    return description
  }
  
}
