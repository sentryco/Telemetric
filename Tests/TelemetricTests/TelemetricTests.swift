import XCTest
@testable import Telemetric

class TelemetricTests: XCTestCase {
   /**
    * Tests the exception event tracking functionality.
    */
   func testException() throws {
      let tracker = Tracker(
         measurementID: measurementID,
         apiSecret: apiSecret,
         // apiEndpoint: "https://www.google-analytics.com/debug/mp/collect",
         clientID: Identity.uniqueUserIdentifier(type: .vendor)
      )
      let expectation = self.expectation(description: "Send esception event")
      let exceptionEvent = Event.exception(description: "Database unavailable", isFatal: false, userAction: "open app")
      tracker.sendEvent(event: exceptionEvent) { _ in expectation.fulfill() }
      self.wait(for: [expectation], timeout: 10.0)
   }
   /**
    * Tests the session event tracking functionality.
    */
   func testSession() throws {
      let tracker = Tracker(
         measurementID: measurementID,
         apiSecret: apiSecret,
         //  apiEndpoint: "https://www.google-analytics.com/debug/mp/collect",
         clientID: Identity.uniqueUserIdentifier(type: .vendor)
      )
      let expectation = self.expectation(description: "Send start session event")
      let startEvent = Event.session(name: "appActive", isStarting: true)
      tracker.sendEvent(event: startEvent) { _ in expectation.fulfill() }
      sleep(4)
      let expectation2 = self.expectation(description: "Send end session event")
      let endEvent = Event.session(name: "appActive", isStarting: false)
      tracker.sendEvent(event: endEvent) { _ in expectation2.fulfill() }
      // let events = [startEvent, endEvent].compactMap { $0 }
      // tracker.sendEvent(events: events) { _ in
      //    expectation.fulfill()
      // }
      self.wait(for: [expectation, expectation2], timeout: 10.0)
   }
   /**
    * Batching. Send on x reached, or every 24h
    */
   func testBatching() throws {
      Telemetric.shared.send(events: [
         Event(name: "event3", params: ["flagging": false]),
         Event(name: "event4", params: ["fiat": 100])
      ])
      Telemetric.shared.send(event: Event.pageView(pageTitle: "welcome"))
      Swift.print("⚠️️ wait")
      sleep(15) // Wait for 20 seconds to let async calls complete
      Swift.print("⏰ timer up")
      Telemetric.shared.send(event: Event.pageView(pageTitle: "signup"))
      sleep(10)
      Swift.print("🏁 all done")
   }
   /**
    * Example usage
    */
   func testBulk() throws {
      let tracker = Tracker(
         measurementID: measurementID,
         apiSecret: apiSecret,
         // This endpoint will return validation messages if there are any issues with your payload
         // apiEndpoint: "https://www.google-analytics.com/debug/mp/collect",
         clientID: Identity.uniqueUserIdentifier(type: .vendor)
      )
      // Create an expectation for a background download task.
      let expectation = self.expectation(description: "Send event")
      let events: [Event] = [
         Event(
            name: "game_continue",
            params: [
               "action": "message shown",
               "label": false,
               "color": 3
            ]
         ),
         Event.exception(description: "Bug occured", isFatal: true),
         Event.customEvent(title: "view_item_list", key: "item_list_name", value: "Home Page"),
         Event.pageView(pageTitle: "prefs_page", engagementTimeMSec: 3200)
      ]
      // let userProps: [String: String] =  [
      //    "newsletter_opt_in": "yes",
      //    "user_total_purchases": "43"
      // ]
      // Send event and fulfill expectation in completion handler
      tracker.sendEvent(events: events/*, userProps: [:]*/) {_ in
         expectation.fulfill()
      }
      // Wait for the expectation to be fulfilled
      self.wait(for: [expectation], timeout: 10.0)
   }
   /**
    * Ensure determinstic 10 digit random string works as expected
    */
   func testRandomString() throws {
      let randomWord: String = String((0..<Int.random(in: 2...20)).map { _ in Character(UnicodeScalar(Int.random(in: 97...122))!) })
      Swift.print("randomWord:  \(randomWord)")
      let words: [String] = [
         randomWord,
         "abracadabra",
         "onboarding",
         "appActiv",
         "af_active",
         "auth"
      ]
      let allSatisfy = words.allSatisfy { word in
         word.consistentRandom10Digits.count == 10 &&
         word.consistentRandom10DigitNumber.count == 10 &&
         word.consistentRandom10Digits == word.consistentRandom10Digits &&
         word.consistentRandom10DigitNumber == word.consistentRandom10DigitNumber
      }
      print("allSatisfy: \(allSatisfy ? "✅" : "❌")")
      XCTAssertTrue(allSatisfy)
   }
   /**
    * Test client id
    * - Fixme: ⚠️️ add more asserts
    * - Note: In GitHub Actions, the environment variable GITHUB_ACTIONS is set to "true".
    */
   func testUserID() throws {
      let clientID: String = Identity.uniqueUserIdentifier(type: .vendor)
      Swift.print("clientID:  \(clientID)")
      let client_id = Payload.randomNumberAndTimestamp(uuidStr: clientID)
      // Swift.print("client_id:  \(client_id)")
      let assert = client_id.count == 21
      Swift.print("client_id.count:  \(client_id.count)")
      Swift.print("client_id:  \(client_id)")
      print("client_id.count == 21: \(assert ? "✅" : "❌")")
      XCTAssertTrue(assert)
   }
   // fixme add doc
   func testRandomNumber() {
      let vendorIDs: [String] = [
         Identity.uniqueUserIdentifier(type: .vendor), // macOS vendor ID
         "C95D99AC-05AE-55D4-8F6B-34FADD53F12B", // GitHub Actions vendor ID
         UUID().uuidString // UUID based vendor ID
      ]
      for vendorID in vendorIDs {
         Swift.print("vendorID:  \(vendorID)")
         let randomNR: String = Payload.randomNumber(uuidStr: vendorID)
         Swift.print("randomNR:  \(randomNR)")
         let assert = randomNR.count == 10
         print("randomNR.count == 10: \(assert ? "✅" : "❌")")
         XCTAssertTrue(assert)
      }
   }
   /**
    * Helps debuging the json format, its sensetive
    */
   fileprivate func testJsonFormat() async throws {
      Swift.print("testJsonFormat")
      let payload: Payload = .init(
         client_id: UUID().uuidString,
         // user_id: UUID().uuidString,
         events: [Event.pageView(pageTitle: "main_page")],
         // user_properties: [:],
         non_personalized_ads: false
      )
      do {
         let encoder = JSONEncoder()
         encoder.outputFormatting = .prettyPrinted // This will format our output to be more readable
         let data = try encoder.encode(payload)
         if let jsonString = String(data: data, encoding: .utf8) {
            print(jsonString)
         }
      } catch {
         print("Error encoding payload: \(error)")
      }
   }
   /**
    * Complex struct coding, bool, numbers etc. GA4 supports this
    */
   fileprivate func testComplexStruct() {
      Swift.print("testComplexStruct")
      //let event = Event(name: "eventName", params: ["key1": "value1", "key2": 42, "values": ["color": "blue", "price": "100"]/**/])
      let event = Event(
         name: "game_start",
         params: [
            "action": "message shown",
            "label": "current_url",
            "values_color": "blue",
            "values_price": 100,
         ]
      )
      let payload = Payload(client_id: "12345", /*user_id: "user123",*/ events: [event], /*user_properties: ["property1": "value1"],*/ non_personalized_ads: false)
      do {
         // Encode the Payload instance to JSON data
         let jsonData = try JSONEncoder().encode(payload)
         // Convert Data to JSON string for display purposes
         if let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString) // Output the JSON string representation in a more readable format
         }
         // Pretty-print the JSON data
         if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
            let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
            let prettyJsonString = String(data: prettyJsonData, encoding: .utf8) {
            print(prettyJsonString) // Output the pretty-printed JSON string
         }
      } catch {
         print("Error encoding to JSON: \(error)")
      }
   }
}
