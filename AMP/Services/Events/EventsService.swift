//
//  EventsService.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 04.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import PromiseKit
import CoreLocation

struct EventService {
  
  private static let baseURL = "https://usefulness.club/amp/sitebackend/0"
  
  struct EventListRequest: Codable {
  
    let action = "getEventsList"
    var filter: Filter
    let token: String
    var maxId: Int?
    let limit: Int
    let offset: Int
    
    struct Filter: Codable {
      let exclude : [String]
      let helps: Bool
      let sort = "create"
      let founds: Bool
      let onlymine = false
      let chats: Bool
      let witness: Bool
      let gibdds: Bool
      let alerts: Bool
      let news: Bool
      let text: String = ""
      let questions: Bool
      let eventsradius: Int = 20
      let onlyactive: Bool
      var lat: Double
      var lon: Double
      let tzone: String = "+07:00"
    }
  }
  
  static private func makeURLRequest(parameters: EventListRequest) throws -> URLRequest {
    var urlRequest = try URLRequest(url: baseURL, method: .post)
    urlRequest.httpBody = try JSONEncoder().encode(parameters)
    return urlRequest
  }
  
  
  static func getEventsList(parameters: EventListRequest) -> Promise<(CLLocation, [Event])> {
    var params = parameters
    var location: CLLocation?
    return CLLocationManager.promise()
      .then {
        location = $0
        params.filter.lat = $0.coordinate.latitude
        params.filter.lon = $0.coordinate.longitude
        let urlRequest = try self.makeURLRequest(parameters: params)
        return Alamofire.request(urlRequest).responseData()
      }
      .then {
        Parser.parseEventList(data: $0)
      }.then { (location!, $0) }
    
  }
  
}
