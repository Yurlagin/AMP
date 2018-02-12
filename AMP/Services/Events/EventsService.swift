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

struct EventService {
  
  private static let baseURL = "https://usefulness.club/amp/sitebackend/0"
  
  struct EventListRequest: Codable {
  
    let action = "getEventsList"
    var filter: Filter
    let token: String
    
    struct Filter: Codable {
      var lat: Double
      var lon: Double
      var eventsradius: Int = 20
      var exclude : [String] = []
      var sort = "create"
      var tzone: String = "+07:00"
      var onlyactive: Bool = true
      var text: String = ""
      var onlymine = false

      var helps: Bool = true
      var founds: Bool = true
      var chats: Bool = true
      var witness: Bool = true
      var gibdds: Bool = true
      var alerts: Bool = true
      var news: Bool = true
      var questions: Bool = true
      
      var maxId: Int?
      var limit: Int = 0
      var offset: Int = 0
      
      init(lat: Double, lon: Double) {
        self.lat = lat
        self.lon = lon
      }
    }
  }
  
  
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
        .then { Parser.parseEventList(data: $0) }
    } catch let error {
      return Promise(error: error)
    }
  }
  
  
  static func send(_ request: LikeRequest) -> (Promise<Event>, Cancel) {
    
    let urlRequest = try! makeURLRequest(parameters: request)
    
    let task = Alamofire.request(urlRequest)
    
    var canceled = false
    
    let cancel = {
      task.cancel()
      canceled = true
    }
    
    return (
      Promise { (fulfill, error) in
        Alamofire.request(urlRequest).responseData()
          .then { Parser.parseEventList(data: $0) }
          .then { events -> () in
            guard !canceled else { return }
            guard let event = events.first else {
              error (NSError(domain: "EventService", code: 2, userInfo: ["reason": "unexpected answer"]))
              return
            }
            fulfill(event)
        }
      },
      cancel)
    
  }
  

  struct LikeRequest: Encodable {
    let token: String
    let action: RequestType
    let eventId: Int
    
    enum RequestType: String, Encodable {
      case addLike
      case removeLike
      case addDisLike
      case removeDisLike
    }
  }

  
}

protocol LikeRequestProtocol {
}

extension EventService.EventListRequest: CustomStringConvertible {
 
  var description: String {
    let mirror = Mirror(reflecting: self)
    return mirror.description
  }
  
  
}
