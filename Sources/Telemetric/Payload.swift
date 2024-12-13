import Foundation

struct Payload: Encodable {
   // A unique identifier for the user
   let client_id: String //  = "1234567890.0987654321"
   let user_id: String
   // An array containing the event details
   let events: [Event]
   // User Properties (Optional)
   // These are attributes that describe the user. Each hit can have up to 25 user properties.
   // ⚠️️ Ensure that the user property you are trying to send has been properly registered in GA4. You need to create the user property in the GA4 Admin section under Custom Definitions before it can be sent with events. Go to GA4 Admin. Under the "Data display" section, click on "Custom definitions"
   // ⚠️️ Doest seem to work yet, figure out how to set this up properly in the admin panel probably, for now pass blank [:] or else the ping is not registered
   let user_properties: [String: String]
   let non_personalized_ads: Bool
}


