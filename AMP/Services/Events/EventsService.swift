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

protocol EventsServiceProtocol {
  func makeRequest(_ commentsRequest: CommentsRequest) -> Promise<CommentsAndQuotes>
  func makeRequest(_ eventRequest: EventRequest) -> Promise<Event>
  func make(_ addCommentRequest: AddCommentRequest) -> Promise<Comment>
}

struct EventsService: EventsServiceProtocol {
  
  private static let bgq = DispatchQueue.global(qos: .userInitiated)
  
  private static let baseURL = "https://usefulness.club/amp/sitebackend/0"
  
  static private func makeURLRequest<T: Encodable>(parameters: T) throws -> URLRequest {
    var urlRequest = try URLRequest(url: baseURL, method: .post)
    let body = try JSONEncoder().encode(parameters)
    urlRequest.httpBody = body
    return urlRequest
  }
  
  
  static func makeEventListRequest(location: CLLocation? = nil,
                                   radius: Int,
                                   limit: Int,
                                   offset: Int,
                                   maxId: Int?,
                                   onlyActive: Bool,
                                   onlyMine: Bool,
                                   excludingIds: [String],
                                   excludingTypes: Set<Event.EventType>,
                                   token: String) -> Promise<(CLLocation, EventListRequest)> {
    
    func makeEventListReaquest(lat: Double, lon: Double) -> EventListRequest {
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
      return Promise(value: (location, makeEventListReaquest(lat: location.coordinate.latitude, lon: location.coordinate.longitude)))
    }
    
    return CLLocationManager.promise()
      .then {
        location = $0
        let coordinate = $0.coordinate
        return Promise(value: makeEventListReaquest(lat: coordinate.latitude, lon: coordinate.longitude))
      }.then {
        (location, $0)
    }
  }

  
  static func make(request: EventListRequest) -> Promise<[Event]> {
    do {
      let urlRequest = try makeURLRequest(parameters: request)
      return Alamofire.request(urlRequest).responseData()
        .then (on: bgq) {
          Parser.parseEventList(data: $0) }
    } catch let error {
      return Promise(error: error)
    }
  }
  
  
  static func make(request: EventsMapRequest) -> Promise<[Event]> {
    do {
      let urlRequest = try makeURLRequest(parameters: request)
      return Alamofire.request(urlRequest).responseData()
        .then (on: bgq) {
          let response = try JSONDecoder().decode(EventsAnswer.self, from: $0)
          if response.answer == request.action {
            return Promise(value: response.events ?? [])
          } else {
            return Promise(error: EventsServiceError.unexpectedAnswer)
          }
      }
    } catch let error {
      return Promise(error: error)
    }
  }
  
  
  static func make(_ request: LikeEventRequest) -> (Promise<Event>, Cancel) {
    
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
          .then (on: bgq) { Parser.parseEventList(data: $0) }
          .then { events -> () in
            guard !canceled else { return }
            guard let event = events.first else {
              error (NSError(domain: "EventService", code: 2, userInfo: ["reason": "unexpected answer"]))
              return
            }
            fulfill(event)
          }.catch {
            error($0)
        }
      },
      cancel)
  }

  
  func makeRequest(_ commentsRequest: CommentsRequest) -> Promise<CommentsAndQuotes> {
    do {
      let commentsRequest = try EventsService.makeURLRequest(parameters: commentsRequest)
      return Alamofire.request(commentsRequest).responseData()
        .then (on: EventsService.bgq) { data in
          let commentsResponse = try JSONDecoder().decode(CommentsResponse.self, from: data)
//          print (commentsResponse)
          if commentsResponse.answer == "getComments" {
            return Promise(value: CommentsAndQuotes(comments: commentsResponse.comments ?? [], replayedComments: commentsResponse.replyedComments))
          } else {
            throw EventsServiceError.unexpectedAnswer
          }
      }
    } catch let error {
      return Promise(error: error)
    }
  }
  
  
  
  func makeRequest(_ eventRequest: EventRequest) -> Promise<Event> {
    do {
      let request = try EventsService.makeURLRequest(parameters: eventRequest)
      return Alamofire.request(request).responseData()
        .then (on: EventsService.bgq) {
          let response = try JSONDecoder().decode(EventsAnswer.self, from: $0)
          if response.answer == "getEvent", let event = response.events?.first {
            return Promise(value: event)
          } else {
            throw EventsServiceError.unexpectedAnswer
          }
      }
    } catch let error {
      return Promise(error: error)
    }
  }

  
  static func send(_ request: LikeCommentRequest) -> (Promise<()>, Cancel) {
    
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
          .then (on: bgq) { data -> () in
            guard !canceled else { return }
            let answer = try JSONDecoder().decode(DefaultAnswer.self, from: data)
            if answer.answer == request.action.rawValue {
              fulfill(())
            } else {
              error (EventsServiceError.unexpectedAnswer)
            }
          }.catch{
            error($0) }
      },
      cancel)
    
  }
  
  
  func make(_ addCommentRequest: AddCommentRequest) -> Promise<Comment> {
    do {
      let request = try EventsService.makeURLRequest(parameters: addCommentRequest)
      return Alamofire.request(request).responseData()
        .then (on: EventsService.bgq) { data in
          let response = try JSONDecoder().decode(CommentsResponse.self, from: data)
          if response.answer == "addComment", let comment = response.comments?.first {
            return Promise(value: comment)
          } else {
            throw EventsServiceError.unexpectedAnswer
          }
      }
    } catch let error {
      return Promise(error: error)
    }
  }
  
  
  static func make(_ request: CreateEventRequest) -> (Promise<Event>, Cancel) {
    
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
          .then (on: bgq) { data -> () in
//            print(String(data: data, encoding: .utf8))
            let eventResponse = try JSONDecoder().decode(CreateEventResponse.self, from: data)
            if !canceled {
              fulfill(eventResponse.event)
            }
          }
          .catch {
            error($0)
        }
      },
      cancel)
  }

  
  
  enum EventsServiceError: Error {
    case unexpectedAnswer
  }
  
}




