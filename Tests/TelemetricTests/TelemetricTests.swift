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
            name: "game_start",
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
   /**/fileprivate func testJsonFormat() async throws {
      Swift.print("testJsonFormat")
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
   /**
    * complex struct coding
    */
   /**/fileprivate func testComplexStruct() {
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
      let payload = Payload(client_id: "12345", /*user_id: "user123",*/ events: [event], user_properties: ["property1": "value1"], non_personalized_ads: false)
      
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
 

 
