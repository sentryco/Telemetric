import XCTest
@testable import Telemetric

extension TelemetricTests {
   // Test Event Serialization:
   // Objective: Ensure that Event instances are correctly serialized into the expected JSON format before being sent to GA4.
       // Start of Selection
       func testEventSerialization() throws {
           let event = Event(name: "test_event", params: ["param1": "value1", "param2": 42])
           let encoder = JSONEncoder()
           let data = try encoder.encode(event)
           XCTAssertNotNil(data)
           
           // Decode the JSON data back to a dictionary
           let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
           XCTAssertEqual(jsonObject?["name"] as? String, "test_event")
           let params = jsonObject?["params"] as? [String: Any]
           XCTAssertNotNil(params)
           XCTAssertEqual(params?["param1"] as? String, "value1")
           XCTAssertEqual(params?["param2"] as? Int, 42)
       }
   // Test Payload with Multiple Events:
    // Objective: Verify that a Payload containing multiple Events is correctly formed.
 
     func testPayloadWithMultipleEvents() throws {
         let events = [
             Event(name: "event1", params: ["key": "value"]),
             Event(name: "event2", params: ["number": 123])
         ]
         let payload = Payload(client_id: "1234567890.0987654321", events: events, non_personalized_ads: false)
         let encoder = JSONEncoder()
         encoder.outputFormatting = .sortedKeys
         let data = try encoder.encode(payload)
         let jsonString = String(data: data, encoding: .utf8)
         XCTAssertNotNil(jsonString)
         // Optionally, check for specific keys or structures in jsonString
     }
    // Test Identity Keychain Persistence:
    // Objective: Ensure that the unique user identifier stored in the keychain persists across multiple accesses.

 
     func testIdentityKeychainPersistence() throws {
         let firstID = Identity.uniqueUserIdentifier(type: .keychain)
         let secondID = Identity.uniqueUserIdentifier(type: .keychain)
         XCTAssertEqual(firstID, secondID, "Keychain IDs should persist and be equal")
     }
 
    // Test EventCollector Batch Sending:
    // Objective: Verify that the EventCollector sends events when the batch size is reached.

 
     func testEventCollectorBatchSizeTrigger() throws {
         let expectation = self.expectation(description: "Events are sent when batch size is reached")
         let collector = EventCollector(batchSize: 3, maxAgeSeconds: 60) { events in
             XCTAssertEqual(events.count, 3)
             expectation.fulfill()
         }

             // Start of Selection
             collector.trackEvent(Event(name: "event1", params: [:]))
             collector.trackEvent(Event(name: "event2", params: [:]))
             collector.trackEvent(Event(name: "event3", params: [:]))

         waitForExpectations(timeout: 5, handler: nil)
     }
     // Test Tracker URL Building:
    // Objective: Ensure that the Tracker correctly builds the URL with the measurement ID and API secret. 

     func testTrackerURLBuilding() {
         let tracker = Tracker(measurementID: "G-TEST123", apiSecret: "SECRET123")
         guard let url = tracker.buildURL() else {
             XCTFail("Failed to build URL")
             return
         }
         let urlString = url.absoluteString
         XCTAssertTrue(urlString.contains("measurement_id=G-TEST123"))
         XCTAssertTrue(urlString.contains("api_secret=SECRET123"))
     }
    // Test Invalid Event Handling in Tracker:
    // Objective: Verify that the Tracker gracefully handles attempts to send empty events.
   func testTrackerWithNoEvents() {
         let tracker = Tracker(measurementID: "G-TEST123", apiSecret: "SECRET123")
         tracker.sendEvent(events: []) { success in
             XCTAssertFalse(success, "Sending empty events should fail")
         }
     }

    // Test Consistent Random 10-Digit Number Generation:
    // Objective: Verify that the consistentRandom10Digits and consistentRandom10DigitNumber properties produce consistent results for the same input.

    func testConsistentRandom10Digits() {
         let testString = "testInput"
         let firstResult = testString.consistentRandom10Digits
         let secondResult = testString.consistentRandom10Digits
         XCTAssertEqual(firstResult, secondResult, "Results should be consistent")
         XCTAssertEqual(firstResult.count, 10, "Result should be 10 digits long")
     }

    // Test System Info Retrieval:
    // Objective: Test the retrieval of system information like app name, version, and screen resolution.

      func testSystemInfo() {
          let appName = System.appName
          XCTAssertFalse(appName.isEmpty, "App name should not be empty")
          
          let appVersion = System.appVersion
          XCTAssertFalse(appVersion.isEmpty, "App version should not be empty")
          
          let screenResolution = System.screenResolution
          XCTAssertFalse(screenResolution.isEmpty, "Screen resolution should not be empty")
      }

      // Test Payload Maximum Size Constraint:
      // Objective: Validate that the Payload does not exceed the maximum allowed size (130kB).
        func testPayloadSizeLimit() throws {
              var events = [Event]()
              for i in 1...25 {
                  events.append(Event(name: "event\(i)", params: ["param": String(repeating: "a", count: 5000)]))
              }
              let payload = Payload(client_id: "1234567890.0987654321", events: events, non_personalized_ads: false)
              let encoder = JSONEncoder()
              let data = try encoder.encode(payload)
              XCTAssertLessThan(data.count, 130 * 1024, "Payload size should be less than 130kB")
          }
        // Test Handling of Special Characters in Event Parameters:
        // Objective: Ensure that special characters in event parameters are correctly encoded and do not cause errors.
    func testEventWithSpecialCharacters() throws {
        let specialString = "Special Characters: !@#$%^&*()_+-=[]{}|;':\",.<>/?"
        let event = Event(name: "special_event", params: ["special_param": specialString])
        let encoder = JSONEncoder()
        let data = try encoder.encode(event)
        let decoder = JSONDecoder()
        let decodedEvent = try decoder.decode(Event.self, from: data)
        XCTAssertEqual(decodedEvent.name, event.name, "Event names should match")
        if let decodedParam = decodedEvent.params["special_param"] as? String {
            XCTAssertEqual(decodedParam, specialString, "Special characters should match after encoding and decoding")
        } else {
            XCTFail("Decoded parameter 'special_param' is not a String")
        }
    }
 
 
}


