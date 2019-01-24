//
//  EventsService.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 04.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import PromiseKit
import CoreLocation
import Alamofire

struct CommentsAndQuotes {
  let comments: [Comment]
  let replayedComments: [Comment]?
}

protocol ApiService {
  func getComments(_ commentsRequest: CommentsRequest) -> Promise<[Comment]>
  func getEvent(_ eventRequest: EventRequest) -> Promise<Event>
  func postComment(_ addCommentRequest: AddCommentRequest) -> Promise<Comment>
  func sendEventLikeDislike(_ request: LikeEventRequest) -> Promise<Event?>
  func sendCommentLikeDislike(_ parameters: LikeCommentRequest) -> Promise<()>
  func getEventsForMap(request: EventsMapRequest) -> Promise<[Event]>
  func postEvent(_ request: CreateEventRequest) -> Promise<Event>
  func cancelPostingEvent()
}

class ApiServiceImpl {
  
  private var apiProvider = ApiProvider()
  
  private let bgq = DispatchQueue.global(qos: .userInitiated)
  private var baseURL: String? { return Constants.baseURL }
  
  private var eventLikeTaskCancellations = [EventId: Cancel]()
  private var eventDislikeTaskCancellations = [EventId: Cancel]()
  private var commentLikeTaskCancellations = [CommentId: Cancel]()
  private var createEventCancellation: Cancel?

  private func makeURLRequest<T: Encodable>(parameters: T) throws -> URLRequest {
    guard let baseURL = baseURL else { throw ApiError.noBaseURL }
    var urlRequest = try URLRequest(url: baseURL, method: .post)
    let body = try JSONEncoder().encode(parameters)
    urlRequest.httpBody = body
    return urlRequest
  }
  
  func makeEventListRequest (
    location: CLLocation? = nil,
    radius: Int,
    limit: Int,
    offset: Int,
    maxId: Int?,
    onlyActive: Bool,
    onlyMine: Bool,
    excludingIds: [String],
    excludingTypes: Set<Event.EventType>,
    token: String) -> Promise<(CLLocation, EventListRequest)> {
    
    func makeEventListRequest(lat: Double, lon: Double) -> EventListRequest {
      var filter = EventListRequest.Filter(lat: lat, lon: lon)
      filter.eventsradius = radius
      filter.onlyactive = onlyActive
      filter.onlymine = onlyMine
      filter.exclude = excludingIds
      filter.alerts = !excludingTypes.contains(.alerts)
      filter.helps = !excludingTypes.contains(.helps)
      filter.founds = !excludingTypes.contains(.founds)
      filter.chats = !excludingTypes.contains(.chats)
      filter.witness = !excludingTypes.contains(.witness)
      filter.gibdds = !excludingTypes.contains(.gibdds)
      filter.news = !excludingTypes.contains(.news)
      filter.questions = !excludingTypes.contains(.questions)
      filter.limit = limit
      filter.offset = offset
      filter.maxId = maxId
      return EventListRequest(filter: filter, token: token)
    }
    
    var location: CLLocation!
    
    guard location == nil else {
      return Promise(value: (location, makeEventListRequest(lat: location.coordinate.latitude,
                                                            lon: location.coordinate.longitude)))
    }
    
    return CLLocationManager.promise()
      .then {
        location = $0
        let coordinate = $0.coordinate
        return Promise(value: makeEventListRequest(lat: coordinate.latitude, lon: coordinate.longitude))
      }.then {
        (location, $0)
    }
  }

  
  func getEvents(request: EventListRequest) -> Promise<[Event]> {
    return Promise { (onResolve, onError) in
      try apiProvider.makeRequest(
        parameters: request,
        onSuccess: { (listResponse: EventsAnswer) in
          if listResponse.answer == request.action, let events = listResponse.events {
            onResolve(events)
          } else {
            onError(ApiError.parsingError(underlyingError: nil))
          }
      },
        onError: onError)
    }
  }
  
  func sendLikeDislike(_ request: LikeEventRequest) -> (Promise<Event?>, Cancel) {
    let urlRequest = try! makeURLRequest(parameters: request)
    let task = Alamofire.request(urlRequest)
    var canceled = false
    let cancel = {
      task.cancel()
      canceled = true
    }
    
    return (
      Promise { (fulfill, error) in
        task.responseData()
          .then (on: bgq, execute: Parser.parseEventList)
          .then { events -> () in
            guard !canceled else { return }
            guard let event = events.first else {
              error (ApiError.parsingError(underlyingError: NSError(domain: "xz", code: 0, userInfo: nil)))
              return
            }
            fulfill(event)}
          .catch(execute: error)
          .always{ [weak self] in self?.removeLikeDislikeCancellation(action: request.action,
                                                                      eventId: request.eventid)}
      },
      cancel)
  }
  
  private func removeLikeDislikeCancellation(action: LikeEventRequest.RequestType, eventId: EventId) {
    switch action {
    case .addLike, .removeLike:
      eventLikeTaskCancellations.removeValue(forKey: eventId)
    case .addDisLike, .removeDisLike:
      eventDislikeTaskCancellations.removeValue(forKey: eventId)
    }
  }
  
  func postComment(_ addCommentRequest: AddCommentRequest) -> Promise<Comment> {
    return Promise { (onSuccess, onError) in
      try apiProvider.makeRequest(
        parameters: addCommentRequest,
        onSuccess: { (response: CommentsResponse) in
          if let comment = response.comments?.first {
            onSuccess(comment)
          } else {
            onError(ApiError.parsingError(underlyingError: nil))
          }
      },
        onError: {
          onError($0)
      })
    }
  }
  
  func uploadAvatar(imageData: Data, request: AMPUploadRequest) -> Promise<[AMPFile]> {
    guard let baseURL = baseURL else { return Promise(error: ApiError.noBaseURL)}
    return Promise { (fulfill, error) in
//      let body = try JSONEncoder().encode(request)
      Alamofire.upload(multipartFormData: { (multipartFormData) in
        multipartFormData.append("{\"action\": \"\(request.action)\", \"token\": \"\(request.token)\"}".data(using: .utf8)!, withName: "body")
        multipartFormData.append(imageData, withName: "file", fileName: "userImage.png", mimeType: "image/png")
//        multipartFormData.append(body, withName: "body")
      }, to: baseURL) { (result) in
        switch result {
        case .success(let request, _, _):
          request
            .responseData()
            .then { data -> () in
              let answer = try JSONDecoder().decode(AMPUploadResponse.self, from: data)
              fulfill(answer.files)
            }.catch { ampError in
              error(ampError)
          }
          
        case .failure(let networkError):
          error(networkError)
        }
      }
    }
  }
  
  func sendProfileSettings(userName: String?, about: String?, token: String) -> Promise<()> {
    let sendProfilerequest = SendProfileRequest (
      token: token,
      keyvalues: [
        ["key": "name", "value": userName ?? ""],
        ["key": "about", "value": about ?? ""]
      ]
    )
    return Promise { (fulfill, error) in
      let urlRequest = try self.makeURLRequest(parameters: sendProfilerequest)
      Alamofire.request(urlRequest).responseData()
        .then (on: bgq) { data -> () in
          let answer = try JSONDecoder().decode(DefaultAnswer.self, from: data)
          if answer.answer == "setSettings" {
            UserDefaults.standard.set(userName, forKey: "name")
            UserDefaults.standard.set(about, forKey: "about")
            fulfill(())
          } else {
            error (EventsServiceError.unexpectedAnswer)
          }
        }.catch { requestError in
          error(requestError)
      }
    }
  }
  
  
  func sendLocation (_ location: CLLocation, token: String) -> (Promise<()>, Cancel) {
    
    let setLocationRequest = SetLocationRequest(token: token, filter: ["lat": location.coordinate.latitude, "lon": location.coordinate.longitude])
    let urlRequest = try! makeURLRequest(parameters: setLocationRequest)
    let task = Alamofire.request(urlRequest)
    var canceled = false
    
    let cancel = {
      task.cancel()
      canceled = true
    }
    
    return (
      Promise { fulfill, error in
        task.responseData()
          .then (on: bgq) { data -> () in
            let response = try JSONDecoder().decode(DefaultAnswer.self, from: data)
            if response.answer == setLocationRequest.action {
              fulfill(())
            } else {
              error(EventsServiceError.unexpectedAnswer)
            }
          }.catch {
            if !canceled {
              error($0)
            }
        }
    }, cancel)
  }

  
   func sendFcmToken(_ fcmToken: String, token: String) -> (Promise<()>, Cancel) {
    let setFcmTokenRequest = SetFirebaseToken(value: fcmToken, token: token)
    let urlRequest = try! makeURLRequest(parameters: setFcmTokenRequest)
    let task = Alamofire.request(urlRequest)
    var canceled = false
    let cancel = {
      task.cancel()
      canceled = true
    }
    
    return (
      Promise { fulfill, error in
        task.responseData()
          .then (on: bgq) { data -> () in
            let response = try JSONDecoder().decode(DefaultAnswer.self, from: data)
            if response.answer == setFcmTokenRequest.action {
              
              fulfill(())
            } else {
              error(EventsServiceError.unexpectedAnswer)
            }
          }.catch {
            if !canceled {
              error($0)
            }
        }
    }, cancel)
  }
  
  enum EventsServiceError: Error {
    case unexpectedAnswer
  }
  
}

extension ApiServiceImpl: ApiService {
  func postEvent(_ request: CreateEventRequest) -> Promise<Event> {
    return
      Promise { (fulfill, error) in
        let dataTask = try apiProvider.makeRequest(
          parameters: request,
          onSuccess: { [weak self] (response: CreateEventResponse) in
            self?.createEventCancellation = nil
            fulfill(response.event)
          },
          onError: error
        )
        createEventCancellation = dataTask.cancel
    }
  }
  
  func cancelPostingEvent() {
    createEventCancellation?()
    createEventCancellation = nil
  }

  func sendEventLikeDislike(_ request: LikeEventRequest) -> Promise<Event?> {
    let eventId = request.eventid
    
    switch request.action {
    case .addLike, .removeLike:
      if let cancelTask = eventLikeTaskCancellations.removeValue(forKey: eventId) {
        cancelTask()
        return Promise(value: nil)
      } else {
        let (eventPromise, cancel) = sendLikeDislike(request)
        eventLikeTaskCancellations[eventId] = cancel
        return eventPromise
      }
      
    case .addDisLike, .removeDisLike:
      if let cancelTask = eventDislikeTaskCancellations.removeValue(forKey: eventId) {
        cancelTask()
        return Promise(value: nil)
      } else {
        let (eventPromise, cancel) = sendLikeDislike(request)
        eventDislikeTaskCancellations[eventId] = cancel
        return eventPromise
      }
    }
    
  }
  
  func getComments(_ commentsRequest: CommentsRequest) -> Promise<[Comment]> {
    return Promise { onResove, onError in
      try apiProvider.makeRequest(
        parameters: commentsRequest,
        onSuccess: { (commentsResponse: CommentsResponse) in
          if commentsResponse.answer == "getComments" {
            onResove(commentsResponse.comments ?? [])
          } else {
            onError(ApiError.parsingError(underlyingError: nil))
          } },
        onError: onError)
    }
  }
  
  func sendCommentLikeDislike(_ parameters: LikeCommentRequest) -> Promise<()> {
    return Promise { [weak self] onResove, onError in
      if let cancel = self?.commentLikeTaskCancellations.removeValue(forKey: parameters.id) {
        cancel()
        onResove(())
      } else {
        try apiProvider.makeRequest(
          parameters: parameters,
          onSuccess: { (commentsResponse: DefaultAnswer) in
            if commentsResponse.answer == parameters.action.rawValue {
              onResove(())
            } else {
              onError(ApiError.parsingError(underlyingError: nil))
            } },
          onError: onError)
      }
    }
  }

  func getEvent(_ eventRequest: EventRequest) -> Promise<Event> {
    do {
      let request = try makeURLRequest(parameters: eventRequest)
      return Alamofire.request(request).responseData()
        .then (on: bgq) {
          let response = try JSONDecoder().decode(EventsAnswer.self, from: $0)
          if response.answer == "getEvent", let event = response.events?.first {
            return Promise(value: event)
          } else {
            throw EventsServiceError.unexpectedAnswer
          }
      }
    } catch {
      return Promise(error: error)
    }
  }
  
  func getEventsForMap(request: EventsMapRequest) -> Promise<[Event]> {
    return Promise { (onResolve, onError) in
      try apiProvider.makeRequest(
        parameters: request,
        onSuccess: { (response: EventsAnswer) in
          if response.answer == request.action, let events = response.events {
            onResolve(events)
          } else {
            onError(ApiError.parsingError(underlyingError: nil))
          }
      },
        onError: onError)
    }
  }
}



