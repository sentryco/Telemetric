import Foundation

struct Event: Encodable {
   // The event name, which should be
   let name: String // might be eventName
   // An object containing various parameters
   // this is String: Any so so we can nest the params. Requires encode and codingkeys to work
   let params: [String: Any] // - Fixme: ⚠️️ might be parameters
}
extension Event {
   // Custom encoding to handle [String: Any]
   func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(name, forKey: .name)
      let paramsData = try JSONSerialization.data(withJSONObject: params, options: [])
      try container.encode(String(data: paramsData, encoding: .utf8), forKey: .params)
   }
   private enum CodingKeys: String, CodingKey {
      case name
      case params
   }
}
