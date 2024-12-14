import XCTest
import Telemetric

class TelemetricTests: XCTestCase {
   /**
    * Example usage
    */
   func testExample() throws {
      let tracker = GA4Tracker(measurementID: "", apiSecret: "")
      // Create an expectation for a background download task.
      let expectation = self.expectation(description: "Send event")
      let events: [Event] = [
         Event(
            name: "game_over",
            params: [
               "action": "message shown",
               "label": "current_url"
            ]
         ),
         Event.customEvent(title: "view_item_list", key: "item_list_name", value: "Home Page"),
         Event.pageView(engagementTimeMSec: "2400")
      ]
      // let userProps: [String: String] =  [
      //    "newsletter_opt_in": "yes",
      //    "user_total_purchases": "43"
      // ]
      // Send event and fulfill expectation in completion handler
      tracker.sendEvent(events: events, userProps: [:]) {_ in
         expectation.fulfill()
      }
      // Wait for the expectation to be fulfilled
      self.wait(for: [expectation], timeout: 10.0)
   }
   /**
    * helps debuging the json format, its sensetive
    */
   fileprivate func testJsonFormat() async throws {
      let payload: Payload = .init(
         client_id: UUID().uuidString,
         // user_id: UUID().uuidString,
         events: [Event.pageView()],
         user_properties: [:],
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
}
 
