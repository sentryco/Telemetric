import Foundation

public struct Payload: Codable {
   /**
    * Client ID is device and browser-specific
    * - Note: Random number and a timestamp  "XXXXXXXXXX.YYYYYYYYYY"
    * - Note: "1234567890.0987654321" 10xNum.10xNum
    * - Note: A unique identifier for the user. This can be generated using UUID() or retrieved from other sources like cookies.
    * - Note: Unique identifier: This is a randomly generated string that uniquely identifies the browser-device pair
    * - Note: Unix timestamp: This represents the exact time and date when the user first interacted with your page. It's stored in microseconds and set in Coordinated Universal Time (UTC)1.
    */
   let client_id: String
   /**
    * - Note: User ID  can track users across multiple devices and browser
    */
   // public let user_id: String
   /**
    * An array containing the event details
    * - Note: (required)
    */
   let events: [Event]
   /**
    * User Properties (Optional)
    * - Description: These are attributes that describe the user. Each hit can have up to 25 user properties.
    * - Note: ⚠️️ Ensure that the user property you are trying to send has been properly registered in GA4. You need to create the user property in the GA4 Admin section under Custom Definitions before it can be sent with events. Go to GA4 Admin. Under the "Data display" section, click on "Custom definitions"
    * - Note: ⚠️️ Doest seem to work yet, figure out how to set this up properly in the admin panel probably, for now pass blank [:] or else the ping is not registered
    * - Note: User Properties (Optional)
    * - Note: These are attributes that describe the user. Each hit can have up to 25 user properties.
    */
   // public let user_properties: [String: String]
   /**
    * Boolean indicating whether to restrict this data for use in personalized advertising.
    * - Note: (optional)
    */
   let non_personalized_ads: Bool
   /**
    * The version of the Measurement Protocol being used.
    * - Note: Measurement Protocol Version (Optional but Recommended)
    * - Fixme: ⚠️️ add doc
    */
   // let v: String = "2"
   /**
    * - Descripion: Timestamp of the event in microseconds. If omitted, GA4 will use the server's time.
    * - Note: Remember to include the timestamp_micros parameter if the event is sent with a delay
    * - Note: Must be within 72 hours of the current time when sending the request
    * - Note: this is needed for session to work
    * - Note: (optional)
    */
   let timestamp_micros: String
   /**
    * Initializes a new instance of `Payload` with the provided parameters.
    * - Parameters:
    *   - client_id: A unique identifier for the user, specific to the device and browser.
    *   - events: An array containing the event details.
    *   - non_personalized_ads: A boolean indicating whether to restrict this data for use in personalized advertising.
    */
   public init(client_id: String, events: [Event], /*user_properties: [String : String],*/ non_personalized_ads: Bool) {
      self.client_id = client_id
      self.events = events
      self.timestamp_micros = String(Int(Date().timeIntervalSince1970 * 1_000_000))
      self.non_personalized_ads = non_personalized_ads
   }
}
extension Payload {
   /**
    * Returns a deterministic 10-digit number based on the provided UUID string and a 10-digit timestamp.
    * - Note: The format of the returned string is "XXXXXXXXXX.YYYYYYYYYY", where "XXXXXXXXXX" is the 10-digit number and "YYYYYYYYYY" is the 10-digit timestamp.
    * - Note: Example: "1234567890.0987654321"
    * - Parameter uuidStr: A string representation of a UUID.
    * - Returns: A string combining a 10-digit number generated from the UUID and a 10-digit timestamp.
    */
   public static func randomNumberAndTimestamp(uuidStr: String) -> String {
      let randomNumber = randomNumber(uuidStr: uuidStr)
      let timestamp = Date().timeIntervalSince1970
      let combinedValue = "\(randomNumber).\(Int(timestamp))"
      return combinedValue
   }
   /**
    * Generates a deterministic 10-digit number based on the provided UUID string.
    * - Parameter uuidStr: A string representation of a UUID.
    * - Returns: A 10-digit string generated from the UUID.
    * - Note: If the provided string is not a valid UUID, a new UUID will be generated.
    */
   public static func randomNumber(uuidStr: String) -> String {
      let uuid = UUID.init(uuidString: uuidStr) ?? UUID()
      let uuidBytes = [UInt8](uuid.uuidString.utf8)
      var result: UInt64 = 0
      for byte in uuidBytes {
         let value = UInt64(byte % 10)
         result = (result * 10 + value) % 1_000_000_0000
      }
      return String(result)
   }
}

 
