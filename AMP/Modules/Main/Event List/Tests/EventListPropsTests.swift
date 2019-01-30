//
//  EventListViewModelTests.swift
//  AMPTests
//
//  Created by Dmitry Yurlagin on 10.02.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import XCTest
import CoreLocation

@testable import AMP

class EventListPropsTests: XCTestCase {
  
  let sampleEvent1 = Event(id: 1, text: "Sample 1 text", date: Date(timeIntervalSince1970: 200))
  let sampleEvent2 = Event(id: 2, text: "Sample 2 text", date: Date(timeIntervalSince1970: 100))
  
  override func setUp() {
    super.setUp()
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testOrderOfEventsInList() {
    let eventListItems = [sampleEvent2, sampleEvent1].asEventStateDict()
    
    let state = EventsState(
      allEvents: eventListItems,
      eventListStatus: .done(
        EventsState.EventList(
          location: CLLocation(),
          eventIds: Set(eventListItems.values.map{$0.event.id}),
          hasMore: true,
          updatingStatus: .none)
      ),
      settings: EventsState.Settings()
    )
    
    XCTAssertNotNil(state.eventListItems)
    let sortedByDateDescendingEvents = eventListItems.values.sorted(by: {$0.event.created > $1.event.created})
    XCTAssertEqual(state.eventListItems, sortedByDateDescendingEvents)
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}

extension Array where Element == Event {
  
  func asEventStateDict() -> [EventId: EventState] {
    return self.reduce([EventId: EventState]()) { (partRes, event) in
      var nextRes = partRes
      nextRes[event.id] = EventState(event: event)
      return nextRes
    }
  }
}

extension Array where Element == EventState {
  
  func asEventStateDict() -> [EventId: EventState] {
    return self.reduce([EventId: EventState]()) { (partRes, eventState) in
      var nextRes = partRes
      nextRes[eventState.event.id] = eventState
      return nextRes
    }
  }
}

