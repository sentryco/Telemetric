import Foundation
import CommonCrypto
import CryptoKit

extension String {
    
   // Generate a consistent random 10-digit string
   
   var consistentRandom10Digits: String {
      // Use SHA256 to create a hash from the entropy string
      let data = Data(self.utf8)
      let hash = SHA256.hash(data: data)
      
      // Take the first 10 digits from the hash
      let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()
      let digits = hashString.compactMap { $0.wholeNumberValue }.prefix(10)
      
      // Ensure it is 10 digits long
      return digits.map(String.init).joined()
   }
   
   // Alternative
   
   var consistentRandom10DigitNumber: String {
      let hashedString = {
         let data = Data(self.utf8)
         var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
         data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
         }
         return hash.map { String(format: "%02x", $0) }.joined()
      }()
      let index = hashedString.index(hashedString.startIndex, offsetBy: 8)
      let first8Characters = hashedString[hashedString.startIndex..<index]
      let number = Int(first8Characters, radix: 16) ?? 0
      return String(number + 1_000_000_000)
   }
   

    
}