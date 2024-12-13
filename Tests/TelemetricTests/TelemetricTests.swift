import XCTest
@testable import Telemetric

class TelemetricTests: XCTestCase {
   
   /*fileprivate*/ func testExample() /*async*/ throws {
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
            name: "purchase",
            params: [
               "credit_card": "visa",
               "items": [
                  "item_id": "item1",
                  "item_name": "Item 1",
                  "custom_item_param1": "value1",
                  "custom_item_param2": "value2"
               ]
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
         "newsletter_opt_in": "yes",
         "user_total_purchases": "43"
         //         "custom_user_param1": "value1",
         //         "custom_user_param2": "value2"
      ]
      _ = userProps
      tracker.sendEvent(events: events, userProps: [:]) {_ in
         expectation.fulfill()
      }
      // Wait for the expectation to be fulfilled
      self.wait(for: [expectation], timeout: 10.0)
   }
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
//func testing() throws {
//   Swift.print("jsonConversion")
//   func jsonEncode(dictionary: [String: Any]) -> String? {
//      do {
//         // Convert dictionary to JSON data
//         let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
//         
//         // Convert JSON data to String
//         let jsonString = String(data: jsonData, encoding: .utf8)
//         
//         return jsonString
//      } catch {
//         print("Error encoding JSON: \(error.localizedDescription)")
//         return nil
//      }
//   }
//   
//   // Example usage
//   let sampleDictionary: [String: Any] = [
//      "name": "John Doe",
//      "age": 30,
//      "isEmployee": true,
//      "department": ["HR", "Finance"]
//   ]
//   
//   if let jsonString = jsonEncode(dictionary: sampleDictionary) {
//      print("JSON Output: \(jsonString)")
//   } else {
//      print("Failed to encode dictionary to JSON.")
//   }
//   }


//func jsonDecode(jsonString: String) -> [String: Any]? {
//   // Convert JSON string to Data
//   guard let jsonData = jsonString.data(using: .utf8) else {
//      print("Error converting string to Data.")
//      return nil
//   }
//   
//   do {
//      // Deserialize the Data back into a dictionary
//      let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
//      return jsonDictionary
//   } catch {
//      print("Error decoding JSON: \(error.localizedDescription)")
//      return nil
//   }
//}
//
//// Example usage
//let jsonString = "{\"name\":\"John Doe\",\"age\":30,\"isEmployee\":true,\"department\":[\"HR\",\"Finance\"]}"
//
//if let decodedDictionary = jsonDecode(jsonString: jsonString) {
//   print("Decoded Dictionary: \(decodedDictionary)")
//} else {
//   print("Failed to decode JSON string.")
//}
