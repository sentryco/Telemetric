import Foundation

public struct Event: Codable {
   /**
    * The event name, which should be
    * - Note: The name of the event. It must be 40 characters or fewer, can only contain alpha-numeric characters and underscores, and must start with an alphabetic character.
    */
   public let name: String // might be eventName
   /**
    * An object containing various parameters
    * - Note: Nested structures are not supported by GA4
    * - Note: Ga4 will accept other values than strings, but presumably it is treated as a string
    */
   public let params: [String: Any]
   /**
    * Initializes a new Event with the given name and parameters.
    * - Parameters:
    *   - name: The name of the event. It must be 40 characters or fewer, can only contain alpha-numeric characters and underscores, and must start with an alphabetic character.
    *   - params: A dictionary containing various parameters for the event. Nested structures are not supported by GA4.
    */
   public init(name: String, params: [String : Any]) {
      self.name = name
      self.params = params
   }
}
/**
 * Codable - Suporting other types than string
 */
extension Event {
   /**
    * Coding keys to map the `Event` properties to the corresponding keys in the encoded data.
    */
   enum CodingKeys: String, CodingKey {
      case name
      case params
   }
   /**
    * Initializes a new instance of `Event` by decoding from the given decoder.
    * - Parameter decoder: The decoder to read data from.
    * - Throws: An error if reading from the decoder fails, or if the data read is corrupted or otherwise invalid.
    */
   public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self) // Create a keyed container using our CodingKeys
      name = try container.decode(String.self, forKey: .name) // Decode the 'name' property from the container
      let paramsDictionary = try container.decode([String: CodableAny].self, forKey: .params) // Decode 'params' as a dictionary with String keys and CodableAny values
      params = paramsDictionary.mapValues { $0.value } // Extract the actual values from CodableAny and assign to 'params'
   }
   /**
    * Encodes this `Event` instance into the given encoder.
    * - Parameter encoder: The encoder to write data to.
    * - Throws: An error if any values are invalid for the given encoder's format.
    */
   public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self) // Create a keyed encoding container using CodingKeys
      try container.encode(name, forKey: .name) // Encode the 'name' property using the key '.name'
      let paramsDictionary = params.mapValues { CodableAny(value: $0) } // Convert 'params' values to 'CodableAny' instances
      try container.encode(paramsDictionary, forKey: .params) // Encode the 'paramsDictionary' using the key '.params'
   }
}
extension Event {
   /**
    * Event.customEvent(title: "view_item_list", key: "item_list_name", value: "Home Page")
    * - Parameters:
    *   - title: The name of the custom event.
    *   - key: The key for the parameter to be included in the event.
    *   - value: The value for the parameter to be included in the event.
    * - Returns: A new instance of `Event` with the specified title and parameters.
    */
   public static func customEvent(title: String, key: String, value: String) -> Event {
      .init(
         name: title,
         params: [key: value]
      )
   }
   /**
    * Event.pageView()
    * - Note: Page view counts as user engagement in GA4
    * - Parameters:
    *   - pageTitle: The title of the page viewed.
    *   - pageLocation: The URL of the page viewed.
    *   - engagementTimeMSec: The engagement time in milliseconds. You need to include the 'engagement_time_msec' parameter with a value of '1', e.g.:
    *   - pageReferrer: The URL of the previous page that referred the user.
    * - Returns: A new instance of `Event` with the specified parameters for a page view.
    */
   public static func pageView(pageTitle: String, pageLocation: String? = nil, engagementTimeMSec: Any? = nil, pageReferrer: String? = nil, screenResolution: String = System.screenResolution, language: String = System.userLanguage) -> Event {
      .init(
         name: "page_view",
         params: ([
            "screen_resolution": screenResolution, // The resolution of the user's screen
            "language": language, // The language setting of the user's browser
            "page_location": pageLocation, // The URL of the page viewed
            "page_title": pageTitle, // The title of the page viewed
            "page_referrer": pageReferrer, // The URL of the previous page that referred the user
            "engagement_time_msec": engagementTimeMSec
            // "page_title": "",
         ] as [String: Any?]).compactMapValues { $0 }
      )
   }
   /**
    * Use this if you track elapsed time your self
    * - Parameters:
    *   - name: your_event_name
    *   - sessionID: xxxxxxxxxx (10 digit random string)
    *   - engagementTimeMSec: mSec elapsed time
    * - Returns: Event
    */
   public static func session(name: String, sessionID: String, engagementTimeMSec: Any) -> Event {
      .init(
         name: name,
         params: [
            "session_id": sessionID // ,
            // - Fixme: ⚠️️ seems like this is de-precated from GA4, which means we can remove TimingTracker, 
            // "engagement_time_msec": engagementTimeMSec
         ]
      )
   }
   /**
    * Creates a session event with the specified name and engagement time.
    * - Parameters:
    *   - name: The name of the event to track.
    *   - isStarting: A boolean indicating whether the session is starting or stopping.
    * - Returns: An optional `Event` instance. Returns `nil` if no start event was previously created for the given name.
    * - Note: This function is optional. It will not create a stop event if no start event was already created for the name.
    * - Note: If a start event is already made for the name, it will be overwritten with a new start time.
    * - Note: The "engagement_time_msec" parameter should contain the engagement time of the event in milliseconds. It represents the amount of time a user has actively engaged with your site or app since the last event was sent.
    * - Note: If you're unsure about the exact engagement time or just want to ensure the event is recorded, you can set it to a minimal value like "1".
    */
   @discardableResult
   public static func session(name: String, isStarting: Bool) -> Event? {
      guard let elapsedTime = TimingTracker.shared.track(event: name, isStarting: isStarting) else { return nil }
      let sessionID: String = name.consistentRandom10Digits
      #if DEBUG
      if isDebugging { print("sessionID: \(sessionID) elapsedTime: \(elapsedTime)") }
      #endif
      return Event.session(
         name: name, // The name of the session event.
         sessionID: sessionID, // The unique session identifier.
         engagementTimeMSec: elapsedTime // The engagement time in milliseconds.
      )
   }
   /**
    * Creates an exception event with the specified parameters.
    * - Parameters:
    *   - name: Use "exception" as the name of the event.
    *   - isFatal: (optional) A boolean that indicates if the exception was fatal to the execution of the program. Example: true (if the app crashed) or false (for recoverable errors).
    *   - description: (optional) A string that describes the exception. A human-readable description of the error, such as an exception type or error message. Example: "IndexOutOfBoundsException in ListAdapter".
    *   - stackTrace: (optional) A string representing the stack trace of the exception. Example: "java.lang.NullPointerException: Attempt to invoke...".
    *   - errorCode: (optional) A string representing the error code associated with the exception. Example: "500".
    *   - userAction: (optional) A string describing the action taken by the user that led to the exception. Example: "Clicked on the submit button".
    *   - environment: (optional) A string describing the environment in which the exception occurred. Example: "Production" or "Development".
    *   - filePath: (optional) A string representing the file path related to the exception. Example: "/user/data/input.txt".
    * - Returns: An `Event` instance representing the exception event.
    */
   public static func exception(description: String? = nil, isFatal: Bool? = nil, stackTrace: String? = nil, errorCode: String? = nil, userAction: String? = nil, environment: String? = nil, filePath: String? = nil) -> Event {
      exception(params:
         ([
            "description": description, // "NullPointerException in MainActivity"
            "fatal": isFatal, // // true or false
            "stack_trace": stackTrace, // "java.lang.NullPointerException: Attempt to invoke...",
            "error_code": errorCode, // // "500"
            "user_action": userAction, // The action taken by the user leading to the exception.
            "environment": environment, // The environment where the exception occurred.
            "file_path": filePath // "/user/data/input.txt",
         ] as [String: Any?]).compactMapValues { $0 }
      )
   }
   /**
    * Creates an exception event with the specified parameters.
    * - Parameters:
    *   - params: A dictionary containing the details of the exception event.
    * - Returns: An `Event` instance representing the exception event.
    */
   public static func exception(params: [String: Any]) -> Event {
      .init(
         name: "exception",
         params: params
      )
   }
}

