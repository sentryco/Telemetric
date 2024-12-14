import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif
/**
 * Identity class for handling unique identifiers.
 * - Fixme: ⚠️️ Rename to id? or keep Identity?
 * - Remark: IFA/IDFA -> Identifier for Advertisers
 * - Remark: IFV/IDFV -> Identifier for Vendor
 * - Remark: IDFA is shared across all apps on the system, but only usable by ad-enabled apps that display ads to the user. Users can opt-out, reset, or disable the “across system” UID, causing a new UID to be generated for each install.
 * - Remark: IDFV is shared between apps from the same publisher, but is lost when the last app of the publisher is uninstalled.
 * - Note: For a complete solution in Objective-C, refer to the following links:
 *   - https://gist.github.com/miguelcma/e8f291e54b025815ca46
 *   - https://github.com/guojunliu/XYUUID
 *   - https://github.com/mushank/ZKUDID
 *   - https://stackoverflow.com/a/20339893/5389500
 *   - https://developer.apple.com/forums/thread/127567
 */
class Identity {}

extension Identity {
   /**
    * Generates a unique user identifier.
    * - Parameter type: Type of identifier (vendor, userDef or keychain)
    */
   internal static func uniqueUserIdentifier(type: IDType) -> String {
      let id: String? = {
         switch type {
         case .vendor: return vendorID // Persistent between runs (in most cases)
         case .userdefault: return userDefaultID // Persistent between runs
         case .keychain: return keychainID // Persistent between installs
         }
      }()
      return id ?? UUID().uuidString
   }
}
/**
 * Extension for handling UIDevice id.
 */
extension Identity {
   /**
    * Vendor identifier source.
    * - Remark: Changes on every simulator run etc (allegedly) - Fixme: ⚠️️ confirm this
    * - Remark: Should persist between release app runs, but beta apps might generate new UUID.
    * - Remark: The MAC doesn't have anything equivalent to iOS's identifierForVendor or advertising Id alas.
    * - Fixme: ⚠️️ for swift 6.0 we will need to fence UIDevice in serlialized main thread. Check with copilot etc
    */
   fileprivate static var vendorID: String? {
      #if os(iOS)
      // For iOS, we return the identifier for vendor
      return UIDevice.current.identifierForVendor?.uuidString
      #elseif os(macOS)
      // For macOS, we need to use IOServiceMatching to get the device
      let dev = IOServiceMatching("IOPlatformExpertDevice")
      // Get the platform expert service
      let platformExpert: io_service_t = IOServiceGetMatchingService(kIOMainPortDefault, dev)
      // Create a property for the platform expert
      let serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformUUIDKey as CFString, kCFAllocatorDefault, 0)
      // Release the platform expert object
      IOObjectRelease(platformExpert)
      // Get the serial number as a CFTypeRef
      let ser: CFTypeRef = serialNumberAsCFString?.takeUnretainedValue() as CFTypeRef
      // If we can cast the serial number to a String, return it
      if let result = ser as? String { return result }
      // If we can't cast the serial number to a String, return nil
      return nil
      #else
      // If the OS is not iOS or macOS, print an error message and return nil
      Swift.print("OS not supported")
      return nil
      #endif
   }
}
/**
 * Extension for handling UserDefault - (Semi persistentID).
 */
extension Identity {
   /**
    * Stores a random UUID that uniquely identifies the user/install using the native UserDefaults . standard.
    * - Remark: The user identifier may be lost if the UserDefaults are cleared or altered in any other way, a new  unique identifier will be created in it's place
    * - Remark: This way, a UUID will be generated once when the app is launched for the first time, and then stored in NSUserDefaults to be retrieved on each subsequent app launch.
    * - Remark: Unlike advertising or vendor identifiers, these identifiers would not be shared across other apps, but for most intents and purposes, this is works just fine.
    * - Remark: Does not persist app reinstalls
    * - Remark: Persist between console-unit-test runs
    */
   fileprivate static var userDefaultID: String? {
      let userDefaults = UserDefaults.standard // Initializes a new UserDefaults object
      if userDefaults.object(forKey: "AppID") == nil { // Checks if the "AppID" key is not set in UserDefaults
         let id: String = Self.vendorID ?? UUID().uuidString // Generates a new UUID if vendorID is nil, otherwise uses the vendorID
         userDefaults.set(id, forKey: "AppID") // Sets the "AppID" key in UserDefaults to the generated or vendor-provided ID
         userDefaults.synchronize() // Synchronizes the UserDefaults changes to disk
      }
      return userDefaults.value(forKey: "AppID") as? String // Returns the "AppID" value from UserDefaults as a String
   }
}
/**
 * Extension for handling Keychain - (Persistent id).
 */
extension Identity {
   /**
    * Creates a new unique user identifier or retrieves the last one created
    * - Description: The `PersistentID` class generates and stores a persistent ID that can be used to identify a device.
    * - Remark: Does not persist OS reset/reinstall. But will persist OS updates and transfers to new phone,
    * - Remark: As long as the bundle identifier remains the same this will persist
    * - Remark: And no, the key will not be synchronized to iCloud by default
    * - Remark: Keychain works with console-unit-tests
    * - Note: For more information, refer to the following links:
    *   - https://stackoverflow.com/questions/41016762/how-to-generate-unique-id-of-device-for-iphone-ipad-using-objective-c/41017285#41017285
    *   - https://github.com/fabiocaccamo/FCUUID
    *   - https://medium.com/@miguelcma/persistent-cross-install-device-identifier-on-ios-using-keychain-ac9e4f84870f
    *   - https://stackoverflow.com/a/38745743/5389500
    *   - https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/AppDistributionGuide/MaintainingCertificates/MaintainingCertificates.html
    */
   fileprivate static var keychainID: String? {
     let uuidKey = "persistentAppID" // This is the key we'll use to store the uuid in the keychain
      if let id = try? Keychain.get(key: uuidKey) { // Check if we already have a uuid stored, if so return it
         return id
      }
      let id = Self.vendorID ?? UUID().uuidString // Generate a new id // UIDevice.current.identifierForVendor?.uuidString else { return nil }
      try? Keychain.set(key: uuidKey, value: id) // Store new identifier in keychain
      return id  // Return new id
   }
}
/**
 * Enum for persistence level.
 * - Description: This enum defines the different types of storage that can be used to store the identity.
 * - Note: The "vendor" option uses the vendor ID to store the identity, but it may not work on macOS.
 * - Note: The "userdefault" option uses UserDefaults to store the identity.
 * - Note: The "keychain" option uses the Keychain to store the identity.
 * - Important: .vendor: Does not work on macOS, or does it now? - Fixme: ⚠️️ confirm this
 */
public enum IDType {
   /**
    * Uses the vendor ID to store the identity
    */
   case vendor
   /**
    * Uses UserDefaults to store the identity
    */
   case userdefault
   /**
    * Uses the Keychain to store the identity
    */
   case keychain
}
