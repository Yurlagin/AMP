//
//  EventReducerTests.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 11/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import XCTest
import CoreLocation
import DifferenceKit

@testable import AMP

extension Event {
  init(id: EventId,
       text: String? = nil,
       date: Date = Date(timeIntervalSince1970: TimeInterval(arc4random_uniform(100)))) {
    self.init(id: id, userName: "Dmitry", avatarUrl: nil, latitude: 12, longitude: 12, address: nil, message: text, type: .chats, created: Date(), howlong: 3500, changed: nil, commentsCount: 0, dislikes: 0, likes: 0, like: false, dislike: false, visible: true, comments: nil, maxCommentId: nil, solutionCommentId: nil)
  }
}

class EventsReducerTests: XCTestCase {
  
  let emptyState = EventsState(
    allEvents: [:],
    eventListStatus: .done(
      EventsState.EventList(
        location: CLLocation(),
        eventIds: [],
        hasMore: true,
        updatingStatus: .none)
    ),
    settings: EventsState.Settings()
  )
  
  let sampleEvent1 = Event(id: 1, text: "Sample 1 text")
  let modifiedSampleEvent1 = Event(id: 1, text: "Sample 1 modified text")
  let sampleEvent2 = Event(id: 2, text: "Sample 2 text")
  let sampleEvent3 = Event(id: 3, text: "Sample 3 text")

  override func setUp() {
    super.setUp()
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testReafreshEventsActionResults() {
    let action = RefreshEventsList(location: CLLocation(), events: [sampleEvent1])
    var state = eventsReducer(action: action, state: emptyState)
    XCTAssertEqual(action.events, state.allEvents.values.map{$0.event})
    XCTAssertEqual(state.eventList?.eventIds, action.events.map{$0.id}.asSet())

    let action2 = RefreshEventsList(location: CLLocation(), events: [sampleEvent2])
    state = eventsReducer(action: action2, state: state)
    XCTAssert(action2.events.asSet().isSubset(of: state.allEvents.values.map{$0.event}.asSet()))
    XCTAssertEqual(state.eventList?.eventIds, action2.events.map{$0.id}.asSet())

    let action3 = RefreshEventsList(location: CLLocation(), events: [modifiedSampleEvent1])
    state = eventsReducer(action: action3, state: state)
    XCTAssert(action3.events.asSet().isSubset(of: state.allEvents.values.map{$0.event}.asSet()))
    XCTAssertEqual(state.eventList?.eventIds, action.events.map{$0.id}.asSet())
    XCTAssert(state.allEvents.count == 2)
    let modifiedEventFromState = state.allEvents.values.map{$0.event}.first(where: modifiedSampleEvent1.isContentEqual)
    XCTAssertEqual(modifiedSampleEvent1, modifiedEventFromState)
  }
  
  func testAppendEventsActionResults() {
    let currentEvents = [sampleEvent2, sampleEvent1]
    var state = EventsState(
      allEvents: currentEvents.asEventStateDict(),
      eventListStatus: .done (
        EventsState.EventList(
          location: CLLocation(),
          eventIds: currentEvents.map{$0.id}.asSet(),
          hasMore: true,
          updatingStatus: .none)
      ),
      settings: EventsState.Settings()
    )
    
    let expectedEventListItems = [sampleEvent1, sampleEvent2, sampleEvent3]
    let appendAction = AppendEventsToList([sampleEvent3])
    state = eventsReducer(action: appendAction, state: state)
    XCTAssertEqual(expectedEventListItems.asEventStateDict(), state.allEvents)
    XCTAssertEqual(state.eventListItems?.map{$0.event}.asSet(), expectedEventListItems.asSet())
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}
