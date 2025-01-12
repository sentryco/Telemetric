import Foundation
/**
 * A type-erased wrapper for Codable values.
 * This struct allows encoding and decoding of values of any type that conforms to Codable.
 */
internal struct CodableAny: Codable {
   let value: Any
   /**
    * Initializes a new instance of `CodableAny` with the provided value.
    * - Parameter value: The value to be wrapped. It can be of any type that conforms to Codable.
    */
   init(value: Any) {
      self.value = value
   }
   /**
    * Encodes this `CodableAny` instance into the given encoder.
    * - Parameter encoder: The encoder to write data to.
    * - Throws: An error if any values are invalid for the given encoder's format.
    */
   func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      if try !encodeValue(value, into: &container) {
         throw EncodingError.invalidValue(value, .init(codingPath: encoder.codingPath, debugDescription: "Unsupported type"))
      }
   }
   /**
    * Helper method to encode a value into the provided container.
    * - Parameters:
    *   - value: The value to encode.
    *   - container: The encoding container.
    * - Returns: A Boolean indicating whether the encoding was successful.
    */
   private func encodeValue(_ value: Any, into container: inout SingleValueEncodingContainer) throws -> Bool {
      switch value {
      case let v as Bool:
         try container.encode(v)
      case let v as Int:
         try container.encode(v)
      case let v as Float:
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
         return false
      }
      return true
   }
   /**
    * Decodes a value of any type that conforms to Codable from the given decoder.
    * - Parameter decoder: The decoder to read data from.
    * - Throws: An error if reading from the decoder fails, or if the data read is corrupted or otherwise invalid.
    */
   init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      if let v = try? container.decode(Bool.self) {
          value = v
      } else if let v = try? container.decode(Int.self) {
          value = v
      } else if let v = try? container.decode(Float.self) {
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
   /**
    * Helper method to decode a value from the provided container.
    * - Parameter container: The decoding container.
    * - Returns: The decoded value as `Any`, or `nil` if decoding fails.
    */
   private func decodeValue(from container: SingleValueDecodingContainer) throws -> Any? {
      if let v = try? container.decode(Bool.self) {
         return v
      } else if let v = try? container.decode(Int.self) {
         return v
      } else if let v = try? container.decode(Float.self) {
         return v
      } else if let v = try? container.decode(Double.self) {
         return v
      } else if let v = try? container.decode(String.self) {
         return v
      } else if let v = try? container.decode([String: String].self) {
         return v
      } else if let v = try? container.decode([CodableAny].self) {
         return v
      } else {
         return nil
      }
   }
}
