import Foundation

struct Event: Encodable {
   // The event name, which should be
   let name: String // might be eventName
   // An object containing various parameters
   // - Fixme: ⚠️️ do String: Encodable. so we can nest the params
   let params: [String: String] // - Fixme: ⚠️️ might be parameters
}
