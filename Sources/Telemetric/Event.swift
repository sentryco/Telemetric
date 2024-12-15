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
    * - Parameters:
    *   - name: - Fixme: ⚠️️ add doc
    *   - params: - Fixme: ⚠️️ add doc
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
   enum CodingKeys: String, CodingKey {
      case name
      case params
   }
   public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      name = try container.decode(String.self, forKey: .name)
      let paramsDictionary = try container.decode([String: CodableAny].self, forKey: .params)
      params = paramsDictionary.mapValues { $0.value }
   }
   public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(name, forKey: .name)
      let paramsDictionary = params.mapValues { CodableAny(value: $0) }
      try container.encode(paramsDictionary, forKey: .params)
   }
}
extension Event {
   /**
    * Event.customEvent(title: "view_item_list", key: "item_list_name", value: "Home Page")
    * - Parameters:
    *   - title: - Fixme: ⚠️️ add doc
    *   - key: - Fixme: ⚠️️ add doc
    *   - value: - Fixme: ⚠️️ add doc
    * - Returns: - Fixme: ⚠️️ add doc
    */
   public static func customEvent(title: String, key: String, value: String) -> Event {
      .init(
         name: title,
         params: [key: value]
      )
   }
   /**
    * Event.pageView()
    * - Note: Page view counts as user engament in GA4
    * - Parameters:
    *   - pageTitle: - Fixme: ⚠️️ add doc
    *   - pageLocation: - Fixme: ⚠️️ add doc
    *   - engagementTimeMSec: measure session/users You need to include the 'engagement_time_msec' parameter with a value of '1', e.g.:
    *   - pageReferrer: - Fixme: ⚠️️ add doc
    * - Returns: - Fixme: ⚠️️ add doc
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
            "session_id": sessionID,
            "engagement_time_msec": engagementTimeMSec
         ]
      )
   }
   /**
    * - Fixme: ⚠️️ add doc
    * - Note: This is optional. As we don't want to create a stop event, if no start event was already created for the name
    * - Note: If a start event is already made for the name, it will be overwritten with a new start time
    * - Note: The "engagement_time_msec" parameter should contain the engagement time of the event in milliseconds. Here are the key points about this parameter:
    * - Note: It represents the amount of time a user has actively engaged with your site or app since the last event was sent
    * - Note: If you're unsure about the exact engagement time or just want to ensure the event is recorded, you can set it to a minimal value like "1"
    */
   @discardableResult
   public static func session(name: String, isStarting: Bool) -> Event? {
      guard let elapsedTime = TimingTracker.shared.track(event: name, isStarting: isStarting) else { return nil }
      let sessionID: String = name.consistentRandom10Digits
      #if DEBUG
      print("sessionID: \(sessionID) elapsedTime: \(elapsedTime)")
      #endif
      return Event.session(
         name: name,
         sessionID: sessionID,
         engagementTimeMSec: elapsedTime // 1 // String(elapsedTime) // "1"
      )
   }
   /**
    * - Fixme: ⚠️️ add doc
    * - Parameters:
    *   - name: Use "exception" as the name of the event.
    *   - isFatal:  (optional) A boolean that indicates if the exception was fatal to the execution of the program. A boolean indicating whether the error was fatal to the application. Example: true (if the app crashed) or false (for recoverable errors).
    *   - description:  (optional) A string that describes the exception. A human-readable description of the error, such as an exception type or error message. Example: "IndexOutOfBoundsException in ListAdapter"
    *   - stackTrace: - Fixme: ⚠️️ add doc
    *   - errorCode: - Fixme: ⚠️️ add doc
    *   - userAction: - Fixme: ⚠️️ add doc
    *   - environment: - Fixme: ⚠️️ add doc
    *   - filePath: - Fixme: ⚠️️ add doc
    * - Returns: - Fixme: ⚠️️ add doc
    */
   public static func exception(/*name: String = "exception", */description: String? = nil, isFatal: Bool? = nil, stackTrace: String? = nil, errorCode: String? = nil, userAction: String? = nil, environment: String? = nil, filePath: String? = nil) -> Event {
      exception(params:
         ([
            "description": description, // "NullPointerException in MainActivity"
            "fatal": isFatal, // // true or false
            "stack_trace": stackTrace, // "java.lang.NullPointerException: Attempt to invoke...",
            "error_code": errorCode, // // "500"
            "user_action": userAction,
            "environment": environment,
            "file_path": filePath // "/user/data/input.txt",
         ] as [String: Any?]).compactMapValues { $0 }
      )
   }
   /**
    * - Fixme: ⚠️️ add doc
    */
   public static func exception(params: [String: Any]) -> Event {
      .init(
         name: "exception",
         params: params
      )
   }
}

