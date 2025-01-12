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
    *   - measurementID: The unique identifier for the Google Analytics 4 property.
    *   - apiSecret: The API secret for the Google Analytics 4 property. This is optional and used for authenticated hits.
    *   - apiEndpoint: The endpoint for sending data to Google Analytics. Defaults to the standard Google Analytics endpoint.
    */
   public init(measurementID: String, apiSecret: String? = nil, apiEndpoint: String = "https://www.google-analytics.com/mp/collect", clientID: String = Identity.uniqueUserIdentifier(type: .vendor)) {
      self.measurementID = measurementID
      self.apiSecret = apiSecret
      self.apiEndpoint = apiEndpoint
      self.clientID = clientID
   }
   /**
    * Sends a single event to Google Analytics.
    * - Parameters:
    *   - event: The event to send. If `nil`, the method returns without sending.
    *   - complete: A completion handler that is called when the request is complete. The boolean parameter indicates whether the request was successful.
    */
   public func sendEvent(event: Event?, complete: ((Bool) -> Void)? = nil) {
      sendEvent(events: [event].compactMap { $0 }, complete: complete)
   }
   /**
    * - Note: URL: https://www.google-analytics.com/mp/collect?measurement_id=G-EMPR3SY5D5&api_secret=YOUR_API_SECRET
    * - Fixme: ⚠️️ Put this on a background thread, see NetTime package for instructions. Confer with copilot etc
    * - Parameters:
    *   - events: The events to send to Google Analytics.
    *   - complete: A completion handler that is called when the request is complete. The boolean parameter indicates whether the request was successful.
    */
   public func sendEvent(events: [Event], complete: ((Bool) -> Void)? = nil) {
      guard !events.isEmpty else { return } // Must have events to send
      
      // Build URL
      guard let url = buildURL() else {
         complete?(false)
         return
      }
      
      // Prepare payload
      let client_id = Payload.randomNumberAndTimestamp(uuidStr: clientID)
      let payload = Payload(
         client_id: client_id,
         events: events,
         non_personalized_ads: false
      )
      
      // Create request
      guard let request = prepareRequest(with: url, payload: payload) else {
         complete?(false)
         return
      }
      
      // Send request
      sendRequest(request, completion: complete)
   }
   /**
    * Sends a single event to Google Analytics.
    *
    * - Parameters:
    *   - event: The event to send. If nil, the call does nothing.
    *   - complete: A completion handler that is called when the request is complete. The boolean parameter indicates whether the request was successful.
    */
   internal func buildURL() -> URL? {
      guard var components = URLComponents(string: apiEndpoint) else {
         // Invalid API endpoint URL
         return nil
      }
      
      // Set query items
      components.queryItems = [
         URLQueryItem(name: "api_secret", value: apiSecret),
         URLQueryItem(name: "measurement_id", value: measurementID)
      ]
      
      // Build URL from components
      return components.url
   }
   /**
   * Prepares a POST URLRequest with the given URL and payload.
   * - Parameters:
   *   - url: The URL to which the request will be sent.
   *   - payload: The payload to include in the request body.
   * - Returns: A configured URLRequest with the payload encoded as JSON in the HTTP body, or nil if encoding fails.
   */
   private func prepareRequest(with url: URL, payload: Payload) -> URLRequest? {
      var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
      request.httpMethod = "POST"
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      
      // Encode payload to JSON
      do {
         let data = try JSONEncoder().encode(payload)
         request.httpBody = data
         return request
      } catch {
         #if DEBUG
         if isDebugging { print("🚫 Failed to encode payload: \(error)") }
         #endif
         return nil
      }
   }
   /**
    * Sends a URLRequest and handles the response.
    *
    * - Parameters:
    *   - request: The URLRequest to send.
    *   - completion: An optional completion handler that is called with a Boolean indicating success or failure.
    */
   private func sendRequest(_ request: URLRequest, completion: ((Bool) -> Void)?) {
      URLSession.shared.dataTask(with: request) { data, response, error in
         self.handleResponse(data: data, response: response, error: error, completion: completion)
      }.resume()
   }
   /**
    * Sends the specified URLRequest and handles the response.
    * - Parameters:
    *   - request: The URLRequest to send.
    *   - completion: An optional completion handler called with a `Bool` indicating whether the request was successful.
    * - Description: Initiates a URLSession data task with the provided request and handles the response asynchronously. The result of the request is passed to the `handleResponse` method for further processing.
    */
   private func handleResponse(data: Data?, response: URLResponse?, error: Error?, completion: ((Bool) -> Void)?) {
      if let error = error {
         #if DEBUG
         if isDebugging { print("🚫 Error: \(error)") }
         #endif
         completion?(false)
         return
      }
      
      guard let httpResponse = response as? HTTPURLResponse else {
         #if DEBUG
         if isDebugging { print("🚫 Invalid response") }
         #endif
         completion?(false)
         return
      }
      
      let statusCode = httpResponse.statusCode
      if statusCode >= 500 {
         #if DEBUG
         if isDebugging { print("🚫 Server error (\(statusCode))") }
         #endif
         completion?(false)
      } else if (200...299).contains(statusCode) {
         #if DEBUG
         if isDebugging { print("✅ Successful upload. Status code: \(statusCode)") }
         #endif
         completion?(true)
      } else {
         #if DEBUG
         if isDebugging { print("⚠️ Unexpected status code: \(statusCode)") }
         #endif
         completion?(false)
      }
      
      // Debug info if the debug endpoint is used
      #if DEBUG
      if self.apiEndpoint == "https://www.google-analytics.com/debug/mp/collect" {
         Swift.print("data?.count: \(String(describing: data?.count))")
         if let data = data, let string = String(data: data, encoding: .utf8) {
            if isDebugging { print("Response String: \(string)") }
         } else {
            if isDebugging { print("Data is nil or not a valid UTF-8 encoded string") }
         }
      }
      #endif
   }
}
internal var isDebugging: Bool = false
