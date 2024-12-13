import Foundation

struct Payload: Encodable {
   // A unique identifier for the user
   let client_id: String //  = "1234567890.0987654321"
   let user_id: String
   // An array containing the event details
   let events: [Event]
   // User Properties (Optional)
   // These are attributes that describe the user. Each hit can have up to 25 user properties.
//   let user_properties: [String: String]
//   let non_personalized_ads: Bool
}

