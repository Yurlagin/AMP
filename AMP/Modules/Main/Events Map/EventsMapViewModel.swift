//
//  EventsMapViewModel.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 03.03.2018.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import Foundation

struct EventsMapViewModel {
  
  let events: Set<EventAnnotation>
  
  let fetchEventsFor: (_ maxLat: Double, _ maxLon: Double, _ minLat: Double, _ minLon: Double) -> ()
  
  init (from state: AppState ) {
    
    self.events = state.eventsState.map
    
    self.fetchEventsFor = { maxLat, maxLon, minLat, minLon in
      
      store.dispatch { state, store in
        guard let token = state.authState.loginStatus.getUserCredentials()?.token else {
          return nil
        }
        
        let excludingTypes = state.eventsState.settings.excludingTypes
        
        let filter = EventsMapRequest.Filter(
          maxLon: maxLon,
          maxLat: maxLat,
          minLon: minLon,
          minLat: minLat,
          exclude: [],
          tzone: "+07:00",
          onlyactive: false,
          onlymine: false,
          helps: !excludingTypes.contains(.helps),
          founds: !excludingTypes.contains(.founds),
          chats: !excludingTypes.contains(.chats),
          witness: !excludingTypes.contains(.witness),
          gibdds: !excludingTypes.contains(.gibdds),
          alerts: !excludingTypes.contains(.alerts),
          news: !excludingTypes.contains(.news),
          questions: !excludingTypes.contains(.questions))
        
        let request = EventsMapRequest(filter: filter, token: token)
        
        EventsService
          .make(request: request)
          .then {
            store.dispatch(AppendEventsToMap(events: $0))
          }.catch { (error) in
            print(error)
          }
        
        return nil
        
      }
      
      
      print ("\(maxLat), \(maxLon), \(minLat), \(minLon)\n")
      
    }
  }
  
}
