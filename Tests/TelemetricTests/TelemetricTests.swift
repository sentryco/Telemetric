import XCTest
@testable import Telemetric

class TelemetricTests: XCTestCase {
    func testExample() /*async*/ throws {
        // Example usage
       let tracker = GA4Tracker(measurementID: "", apiSecret: "")
        // Create an expectation for a background download task.
        let expectation = self.expectation(description: "Send event")
        // Send event and fulfill expectation in completion handler
       let events: [Event] = [
         Event(
            name: "view_item_list",
            params: ["item_list_name": "Home Page"]
         ),
         Event(
            name: "game_over",
            params: [
               "action": "message shown",
               "label": "current_url"
            ]
         ),
         Event(
            name: "page_view",
            params: [
               "page_location": "https://www.example.com/home",
               "page_title": "Home Page",
               "page_referrer": "https://www.google.com",
               "engagement_time_msec": "15000"
            ]
         )
       ]
       let userProps: [String: String] =  [
//         "newsletter_opt_in": "yes",
//         "user_total_purchases": "43"
         "custom_user_param1": "value1",
         "custom_user_param2": "value2"
       ]
       tracker.sendEvent(events: events, userProps: userProps) {_ in
            expectation.fulfill()
        }
        // Wait for the expectation to be fulfilled
       self.wait(for: [expectation], timeout: 10.0)
    }
//   /*fileprivate*/ func testJsonFormat() async throws {
//       let parameters = [
//         "page_location": "https://www.example.com/home",
//         "page_title": "Home Page",
//         "page_referrer": "https://www.google.com",
//         "engagement_time_msec": "15000"
//       ]
//       
//       let payload: Payload = .init(
//         client_id: UUID().uuidString,
////         user_id: UUID().uuidString,
//         events: [.init(name: "page_view"/*"view_item_list"*/,
//         params: parameters /*["item_list_name": "Home Page"]*/)]
////         user_properties: [:],
////         non_personalized_ads: false/*, *//* non_personalized_ads: false*/
//       )
//      do {
//         let encoder = JSONEncoder()
//         encoder.outputFormatting = .prettyPrinted // This will format our output to be more readable
//         let data = try encoder.encode(payload)
//         if let jsonString = String(data: data, encoding: .utf8) {
//            print(jsonString)
//         }
//      } catch {
//         print("Error encoding payload: \(error)")
//      }
//   }
}
