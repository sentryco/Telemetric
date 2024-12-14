import Foundation
/**
 * A class that provides a simple getter and setter wrapper for keychain.
 * This class is used to securely store and retrieve data from the keychain.
 * - Note: This code is adapted from: https://stackoverflow.com/a/51642962/5389500
 */
internal class Keychain {
   /**
    * Set value for key in keychain.
    * This function is used to store a string value in the keychain associated with a given key.
    * - Parameters:
    *   - key: The key with which the value is associated in the keychain.
    *   - value: The string value to be stored in the keychain.
    */
   internal static func set(key: String, value: String) throws {
      // Convert the string value to data
      guard let valueData: Data = value.data(using: .utf8) else {
         Swift.print("Keychain: Unable to store data, invalid input - key: \(key), value: \(value)")
         return
      }
      // Try to delete any existing value associated with the key
      do {
         try delete(itemKey: key) // Tries to delete the keychain item with the specified key
      } catch {
         Swift.print("Keychain: nothing to delete...") // Prints an error message if the keychain item cannot be deleted
      }
      // Define the query for adding the item to the keychain
      let queryAdd: [String: AnyObject] = [
         kSecClass as String: kSecClassGenericPassword, // Define the class of the item that this query will add
         kSecAttrAccount as String: key as AnyObject, // Define the account attribute of the item
         kSecValueData as String: valueData as AnyObject, // Define the data to be stored in the keychain
         kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked // Define when the item is accessible
      ]
      // Add the item to the keychain
      let resultCode: OSStatus = SecItemAdd(queryAdd as CFDictionary, nil)
      if resultCode != 0 {
         print("Keychain: value not added - Error: \(resultCode)")
      } else {
         print("Keychain: value added successfully")
      }
   }
   /**
    * Get value from keychain.
    * This function is used to retrieve a string value from the keychain associated with a given key.
    * - Parameter key: The key with which the value is associated in the keychain.
    * - Returns: The string value associated with the key, or nil if no value is found.
    */
   internal static func get(key: String) throws -> String? {
      let queryLoad: [String: AnyObject] = [ // Define the query for loading the item from the keychain
         kSecClass as String: kSecClassGenericPassword, // Define the class of the item that this query will load
         kSecAttrAccount as String: key as AnyObject, // Define the account attribute of the item
         kSecReturnData as String: kCFBooleanTrue, // Define that the data of the item should be returned
         kSecMatchLimit as String: kSecMatchLimitOne // Define that only one item should be returned
      ]
      var result: AnyObject?
      // Load the item from the keychain
      let resultCodeLoad: OSStatus = withUnsafeMutablePointer(to: &result) {
         SecItemCopyMatching(queryLoad as CFDictionary, UnsafeMutablePointer($0))
      }
      if resultCodeLoad != 0 { // Checks if the result code for loading the keychain data is not 0
         print("Keychain: unable to load data - \(resultCodeLoad)") // Prints an error message with the result code if the keychain data cannot be loaded
         return nil // Returns nil if the keychain data cannot be loaded
      }
      // Convert the data to a string
      guard let resultVal: NSData = result as? NSData,
            let keyValue: String = NSString(data: resultVal as Data, encoding: String.Encoding.utf8.rawValue) as String? else {
         print("Keychain: error parsing keychain result - \(resultCodeLoad)")
         return nil
      }
      return keyValue
   }
}
/**
 * An extension of the Keychain class that provides a helper function for deleting items from the keychain.
 */
extension Keychain {
   /**
    * Delete an item from the keychain.
    * This function is used to delete the value associated with a given key from the keychain.
    * - Parameter itemKey: The key of the item to be deleted from the keychain.
    */
   fileprivate static func delete(itemKey: String) throws {
      // Define the query for deleting the item from the keychain
      let queryDelete: [String: AnyObject] = [
         kSecClass as String: kSecClassGenericPassword, // Define the class of the item that this query will delete
         kSecAttrAccount as String: itemKey as AnyObject // Define the account attribute of the item to be deleted
      ]
      // Delete the item from the keychain
      let resultCodeDelete: OSStatus = SecItemDelete(queryDelete as CFDictionary)
      if resultCodeDelete != 0 { // Checks if the result code for deleting the keychain item is not 0
         print("Keychain: unable to delete from keychain: \(resultCodeDelete)") // Prints an error message with the result code if the keychain item cannot be deleted
      } else {
         print("Keychain: successfully deleted item") // Prints a success message if the keychain item is deleted successfully
      }
   }
}
