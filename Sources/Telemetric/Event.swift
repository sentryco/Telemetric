import Foundation

public struct Event: Encodable {
   /**
    * The event name, which should be
    * - Note: The name of the event. It must be 40 characters or fewer, can only contain alpha-numeric characters and underscores, and must start with an alphabetic character.
    */
   public let name: String // might be eventName
   /**
    * An object containing various parameters
    * - Not: This is String: Any so so we can nest the params. Requires encode and codingkeys to work
    */
   public let params: [String: String] // - Fixme: ⚠️️ might be parameters
   /**
    * - Parameters:
    *   - name: - Fixme: ⚠️️ add doc
    *   - params: - Fixme: ⚠️️ add doc
    */
   public init(name: String, params: [String : String]) {
      self.name = name
      self.params = params
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
    * - Parameters:
    *   - pageTitle: - Fixme: ⚠️️ add doc
    *   - pageLocation: - Fixme: ⚠️️ add doc
    *   - engagementTimeMSec: - Fixme: ⚠️️ add doc
    *   - pageReferrer: - Fixme: ⚠️️ add doc
    * - Returns: - Fixme: ⚠️️ add doc
    */
   public static func pageView(pageTitle: String = "Home Page", pageLocation: String = "https://www.example.com/home", engagementTimeMSec: String = "1500", pageReferrer: String = "https://www.google.com") -> Event {
      .init(
         name: "page_view",
         params: [
            "screen_resolution": System.screenResolution, // The resolution of the user's screen
            "language": System.userLanguage, // The language setting of the user's browser
            "page_location": pageLocation, // The URL of the page viewed
            "page_title": pageTitle, // The title of the page viewed
            "page_referrer": pageReferrer, // The URL of the previous page that referred the user
            "engagement_time_msec": engagementTimeMSec
            // "page_title": "",
         ]
      )
   }
}

