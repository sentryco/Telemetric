import Foundation

internal struct CodableAny: Codable {
   let value: Any
   
   init(value: Any) {
      self.value = value
   }
   
   func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      switch value {
      case let v as Bool:
         try container.encode(v)
      case let v as Int:
         try container.encode(v)
      case let v as Double:
         try container.encode(v)
      case let v as String:
         try container.encode(v)
      case let v as [String: String]:
         try container.encode(v)
      case let v as [CodableAny]:
         try container.encode(v)
      default:
         throw EncodingError.invalidValue(value, .init(codingPath: [], debugDescription: "Unsupported type"))
      }
   }
   
   init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      if let v = try? container.decode(Bool.self) {
         value = v
      } else if let v = try? container.decode(Int.self) {
         value = v
      } else if let v = try? container.decode(Double.self) {
         value = v
      } else if let v = try? container.decode(String.self) {
         value = v
      } else if let v = try? container.decode([String: String].self) {
         value = v
      } else if let v = try? container.decode([CodableAny].self) {
         value = v
      } else {
         throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported type")
      }
   }
}
