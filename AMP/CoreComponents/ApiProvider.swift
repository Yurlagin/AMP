//
//  ApiProvider.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 19/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import Alamofire

//protocol ApiProvider {
//  func sendRequest
//}

class ApiProvider {
  private var baseURL: String? { return Constants.baseURL }

  @discardableResult
  func makeRequest<InputType: Encodable, ResponseType: Decodable>(
    parameters: InputType,
    method: HTTPMethod = .post,
    onSuccess: ((ResponseType) -> Void)? = nil,
    onCancel: (() -> Void)? = nil,
    onError: ((ApiError) -> Void)? = nil
    ) throws -> DataRequest {
    
    guard let baseURL = baseURL else { throw ApiError.noBaseURL }
    var urlRequest = try URLRequest(url: baseURL, method: method)
    let body = try JSONEncoder().encode(parameters)
    urlRequest.httpBody = body
    print("--> URL Request: \(String(describing: urlRequest.urlRequest)) \nMethod: \(String(describing: urlRequest.httpMethod)) \nBody: \(try! JSONSerialization.jsonObject(with: urlRequest.httpBody!))")
    return Alamofire
      .request(urlRequest)
      .responseData { (response) in
        print ("<-- URL Response: \(String(describing: response))")
        switch response.result {
        case .success(let data):
          do {
            if let json = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]) {
              print("body: \(json)")
            }
            let model = try JSONDecoder().decode(ResponseType.self, from: data)
            onSuccess?(model)
          } catch {
            onError?(ApiError.parsingError(underlyingError: error))
          }
          
        case .failure(let error):
          switch error {
          case let error as URLError:
            if error.code == URLError.cancelled {
              onCancel?()
            } else {
              onError?(ApiError.network(underlyingError: error))
            }
            
          case let error as AFError:
            onError?(ApiError.network(underlyingError: error))
            
          default:
            assertionFailure("Error should be URLError or AFError only")
          }
        }
    }
  }
  
  
}

