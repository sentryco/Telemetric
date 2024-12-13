import Foundation

class GA4Tracker {
   let measurementID: String
   let apiSecret: String?
   /**
    * - Note: ga4 endpoint: https://www.google-analytics.com/g/collect
    * - Note: endPointValidation: https://www.google-analytics.com/debug/mp/collect
    * - Note: Debug: "https://www.google-analytics.com/debug/mp/collect"
    */
   let apiEndpoint = "https://www.google-analytics.com/mp/collect" // "https://www.google-analytics.com/g/collect" 
   init(measurementID: String, apiSecret: String? = nil) {
      self.measurementID = measurementID
      self.apiSecret = apiSecret
   }
   /**
    * - Note: url: https://www.google-analytics.com/mp/collect?measurement_id=G-EMPR3SY5D5&api_secret=YOUR_API_SECRET
    */
   func sendEvent(events: [Event], userProps: [String: String], complete: ((Bool) -> Void)? = nil) {
//      Swift.print("sendEvent")
      var components = URLComponents(string: apiEndpoint)
      components?.queryItems = [
         URLQueryItem(name: "api_secret", value: apiSecret), // Optional, for authenticated hits, I think gtag flavour requires apisecret ref: https://github.com/adswerve/GA4-Measurement-Protocol-Apple-tvOS/blob/main/Example/tvOSTestApp/tvOSTestApp/GA4MPClient.swift
         URLQueryItem(name: "measurement_id", value: measurementID),
      ]
      guard let url = components?.url else { return }
//      Swift.print("url.absoluteString:  \(url.absoluteString)")
      var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
      request.httpMethod = "POST"
      let payload: Payload = .init(
         client_id: UUID().uuidString/*"1234.1234"*/, // "1234567890.0987654321" // UUID().uuidString, /*""*//*"1234567890.0987654321"*/ // - Fixme: ⚠️️ try UUID().uuidString here as well?
         user_id: UUID().uuidString,
         events: events//,//,//,
//         user_properties: userProps
//         non_personalized_ads: false
      )
      let data: Data? = try? JSONEncoder().encode(payload)
      request.httpBody = data
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      URLSession.shared.dataTask(with: request) { (data, response, error) in
         if let error = error {
            print("🚫 Error: \(error)")
            complete?(false)
         }
         if let response = response {
//            print("Response: \(response)")
            if let response = response as? HTTPURLResponse {
               let statusCode = response.statusCode
               if statusCode >= 500 {
                  print("🚫 Server error (\(statusCode))' upload")
                  // - Fixme: ⚠️️ Implement backoff and retry logic
                  complete?(false)
               } else {
                  // presumed success
                  print("✅ Successful upload. Status code: \(statusCode)")
                  complete?(true)
               }
            }
         }
//         if let data = data {
//            let str = String(data: data, encoding: .utf8)
////            print("👇 Received data:\n\(str ?? "")")
////            print("data.count: \(data.count)")
//            if data.count > 0 {
//               Swift.print("data downloaded: \(data.count)")
//               Swift.print("str:  \(String(describing: str))")
//            }
//            complete?(true)
//         }
      }.resume()
   }
}
