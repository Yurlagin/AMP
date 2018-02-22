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


protocol EventsServiceProtocol {
  func makeRequest(_ commentsRequest: CommentsRequest) -> Promise<[Comment]>
  func makeRequest(_ commentsRequest: EventRequest) -> Promise<Event>
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

  
  static func getEventsList(request: EventListRequest) -> Promise<[Event]> {
    do {
      let urlRequest = try makeURLRequest(parameters: request)
      return Alamofire.request(urlRequest).responseData()
        .then (on: bgq) {
          Parser.parseEventList(data: $0) }
    } catch let error {
      return Promise(error: error)
    }
  }
  
  
  static func send(_ request: LikeEventRequest) -> (Promise<Event>, Cancel) {
    
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

  
  
  func makeRequest(_ commentsRequest: CommentsRequest) -> Promise<[Comment]> {
    do {
      let commentsRequest = try EventsService.makeURLRequest(parameters: commentsRequest)
      return Alamofire.request(commentsRequest).responseData()
        .then (on: EventsService.bgq) {
          let commentsResponse = try JSONDecoder().decode(CommentsResponse.self, from: $0)
          print ("ccc")
          if commentsResponse.answer == "getComments" {
            return Promise(value: commentsResponse.comments ?? [])
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
          let response = try JSONDecoder().decode(EventListAnswer.self, from: $0)
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

  
  
  enum EventsServiceError: Error {
    case unexpectedAnswer
  }
  
}




