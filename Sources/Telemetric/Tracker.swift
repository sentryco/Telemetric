import Foundation
/**
 * The google analytics 4 tracker
 */
public class Tracker {
   /**
    * Measurement ID
    */
   let measurementID: String
   /**
    * API secret
    * - Fixme: ⚠️️ make this non optional?
    */
   let apiSecret: String?
   /**
    * End point
    */
   let apiEndpoint: String
   /**
    * client id
    */
   let clientID: String
   /**
    * Init
    * - Parameters:
    *   - measurementID: - Fixme: ⚠️️ add doc
    *   - apiSecret: - Fixme: ⚠️️ add doc
    *   - apiEndpoint: - Fixme: ⚠️️ add doc
    */
   public init(measurementID: String, apiSecret: String? = nil, apiEndpoint: String = "https://www.google-analytics.com/mp/collect", clientID: String = Identity.uniqueUserIdentifier(type: .vendor)) {
      self.measurementID = measurementID
      self.apiSecret = apiSecret
      self.apiEndpoint = apiEndpoint
      self.clientID = clientID
   }
   /**
    * Convenient
    */
   public func sendEvent(event: Event?, complete: ((Bool) -> Void)? = nil) {
      sendEvent(events: [event].compactMap { $0 }, complete: complete)
   }
   /**
    * - Note: URL: https://www.google-analytics.com/mp/collect?measurement_id=G-EMPR3SY5D5&api_secret=YOUR_API_SECRET
    * - Fixme: ⚠️️ Put this on a background thread, see NetTime package for instructions. Confer with copilot etc
    * - Parameters:
    *   - events: - Fixme: ⚠️️ add doc
    *   - userProps: - Fixme: ⚠️️ add doc
    *   - complete: - Fixme: ⚠️️ add doc
    */
   public func sendEvent(events: [Event], /*userProps: [String: String] = [:],*/ complete: ((Bool) -> Void)? = nil) {
      guard !events.isEmpty else { return } // must have events to send
//      #if DEBUG
//      Swift.print("sendEvent")
//      #endif
      var components = URLComponents(string: apiEndpoint)
      components?.queryItems = [
         URLQueryItem(name: "api_secret", value: apiSecret), // Optional, for authenticated hits, I think gtag flavour requires apisecret ref: https://github.com/adswerve/GA4-Measurement-Protocol-Apple-tvOS/blob/main/Example/tvOSTestApp/tvOSTestApp/GA4MPClient.swift
         URLQueryItem(name: "measurement_id", value: measurementID),
      ]
      guard let url = components?.url else { return }
      var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
      request.httpMethod = "POST"
      let client_id: String = /*"GA1.1." + */Payload.randomNumberAndTimestamp(uuidStr: clientID)
//      #if DEBUG
//      Swift.print("client_id: \(client_id)")
//      #endif
      let payload: Payload = .init(
         client_id: client_id,
         // user_id: UUID().uuidString,
         events: events,
         /*user_properties: userProps,*/
         non_personalized_ads: false
      )
      let data: Data? = try? JSONEncoder().encode(payload)
      request.httpBody = data
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      URLSession.shared.dataTask(with: request) { (data, response, error) in
         if let error = error {
            #if DEBUG
            print("🚫 Error: \(error)")
            #endif
            complete?(false)
         }
         if let response = response {
            if let response = response as? HTTPURLResponse {
               let statusCode = response.statusCode
               if statusCode >= 500 {
                  #if DEBUG
                  print("🚫 Server error (\(statusCode))' upload")
                  #endif
                  // - Fixme: ⚠️️ Implement backoff and retry logic
                  complete?(false)
               } else { // presumed success
                  #if DEBUG
                  print("✅ Successful upload. Status code: \(statusCode)") // If format or id is wrong this still returns success. Check your ga4 dashboard to confirm if things works
                  #endif
                  complete?(true)
               }
            }
         }
         // This has debug info if payload is in the wrong format or is incorrect. If the debug endpont is used
//         #if DEBUG
         // Swift.print("data?.count:  \(String(describing: data?.count))")
//         if let data = data, let string = String(data: data, encoding: .utf8) {
//            print("String: \(string)")
//         } else {
//            print("Data is nil or not a valid UTF-8 encoded string")
//         }
//         #endif
      }.resume()
   }
}
