import Foundation

public class GA4Tracker {
   /**
    * Measurement ID
    */
   let measurementID: String
   /**
    * API secret
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
   public init(measurementID: String, apiSecret: String? = nil, apiEndpoint: String = "https://www.google-analytics.com/mp/collect", clientID: String = defaultClientID) {
      self.measurementID = measurementID
      self.apiSecret = apiSecret
      self.apiEndpoint = apiEndpoint
      self.clientID = clientID
   }
   /**
    * - Note: url: https://www.google-analytics.com/mp/collect?measurement_id=G-EMPR3SY5D5&api_secret=YOUR_API_SECRET
    * - Parameters:
    *   - events: - Fixme: ⚠️️ add doc
    *   - userProps: - Fixme: ⚠️️ add doc
    *   - complete: - Fixme: ⚠️️ add doc
    */
   public func sendEvent(events: [Event], userProps: [String: String], complete: ((Bool) -> Void)? = nil) {
      var components = URLComponents(string: apiEndpoint)
      components?.queryItems = [
         URLQueryItem(name: "api_secret", value: apiSecret), // Optional, for authenticated hits, I think gtag flavour requires apisecret ref: https://github.com/adswerve/GA4-Measurement-Protocol-Apple-tvOS/blob/main/Example/tvOSTestApp/tvOSTestApp/GA4MPClient.swift
         URLQueryItem(name: "measurement_id", value: measurementID),
      ]
      guard let url = components?.url else { return }
      var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
      request.httpMethod = "POST"
      let payload: Payload = .init(
         client_id: Payload.randomNumberAndTimestamp(uuidStr: clientID),
         // user_id: UUID().uuidString,
         events: events,
         user_properties: userProps,
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
                  print("✅ Successful upload. Status code: \(statusCode)")
                  #endif
                  complete?(true)
               }
            }
         }
      }.resume()
   }
}
// keeping this here avoids exposing Identity api
public var defaultClientID: String = Identity.uniqueUserIdentifier(type: .userdefault)
