//
//  EventsMapViewModel.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 03.03.2018.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import Foundation

struct EventsMapViewModel {
  
  let events: [Event]
  
  let shouldShowEvent: EventId?
  
  let eventShown: () -> ()
  
  let fetchEventsFor: (_ maxLat: Double, _ maxLon: Double, _ minLat: Double, _ minLon: Double) -> ()
  
  init (from state: AppState ) {
    
    self.events = state.eventsState.mapEvents
    
    self.shouldShowEvent = state.eventsState.shouldShowEvent
    
    self.eventShown = { store.dispatch(EventShown()) }
    
    self.fetchEventsFor = { maxLat, maxLon, minLat, minLon in
      
      store.dispatch { state, store in
        guard let token = state.authState.loginStatus.getUserCredentials()?.token else {
          return nil
        }
        
        let excludingTypes = state.eventsState.settings.excludingTypes
        
        let startDate = Date().addingTimeInterval(-3 * 60 * 60)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let filter = EventsMapRequest.Filter(
          maxLon: maxLon,
          maxLat: maxLat,
          minLon: minLon,
          minLat: minLat,
          fromDate: formatter.string(from: startDate),
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
        
        ApiService
          .make(request: request)
          .then {
            store.dispatch(AppendEventsToMap(events: $0))
          }.catch { (error) in
            print(error)
          }
        
        return nil
        
      }
      
      
      
    }
  }
  
}
