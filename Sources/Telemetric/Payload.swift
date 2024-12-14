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
   public let client_id: String
   /**
    * - Note: User ID  can track users across multiple devices and browser
    */
   // public let user_id: String
   /**
    * An array containing the event details
    */
   public let events: [Event]
   /**
    * User Properties (Optional)
    * - Description: These are attributes that describe the user. Each hit can have up to 25 user properties.
    * - Note: ⚠️️ Ensure that the user property you are trying to send has been properly registered in GA4. You need to create the user property in the GA4 Admin section under Custom Definitions before it can be sent with events. Go to GA4 Admin. Under the "Data display" section, click on "Custom definitions"
    * - Note: ⚠️️ Doest seem to work yet, figure out how to set this up properly in the admin panel probably, for now pass blank [:] or else the ping is not registered
    * - Note: User Properties (Optional)
    * - Note: These are attributes that describe the user. Each hit can have up to 25 user properties.
    */
   public let user_properties: [String: String]
   /**
    * - Fixme: ⚠️️ add doc
    */
   public let non_personalized_ads: Bool
   /**
    * The version of the Measurement Protocol being used.
    * - Note: Measurement Protocol Version (Optional but Recommended)
    * - Fixme: ⚠️️ add doc
    */
   // let v: String = "2"
   /**
    * - Fixme: ⚠️️ add doc
    * - Parameters:
    *   - client_id: - Fixme: ⚠️️ add doc
    *   - events: - Fixme: ⚠️️ add doc
    *   - user_properties: - Fixme: ⚠️️ add doc
    *   - non_personalized_ads: - Fixme: ⚠️️ add doc
    */
   public init(client_id: String, events: [Event], user_properties: [String : String], non_personalized_ads: Bool) {
      self.client_id = client_id
      self.events = events
      self.user_properties = user_properties
      self.non_personalized_ads = non_personalized_ads
   }
}
extension Payload {
   /**
    * Returns deterministic 10 Digit Number based on uuid, and 10 digit date
    * - Fixme: ⚠️️ add doc, use copilot
    * - Note: Random number and a timestamp  "XXXXXXXXXX.YYYYYYYYYY"
    * - Note: "1234567890.0987654321" 10xNum.10xNum
    * - Parameter uuidStr: - Fixme: ⚠️️ add doc
    * - Returns: - Fixme: ⚠️️ add doc
    */
   static func randomNumberAndTimestamp(uuidStr: String) -> String {
      let uuid = UUID.init(uuidString: uuidStr) ?? UUID()
      let uuidBytes = [UInt8](uuid.uuidString.utf8)
      let randomNumber = uuidBytes.reduce(0) { ($0 * 10 + UInt64($1 % 10)) % 1_000_000_0000 }
      let timestamp = Date().timeIntervalSince1970
      let combinedValue = "\(randomNumber).\(Int(timestamp))"
      return combinedValue
   }
}

 
