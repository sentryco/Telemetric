import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif
/**
 * System class provides access to various system-level properties.
 * - Fixme: Consider moving this to a Bundle extension for better organization.
 */
internal class System {
   /**
    * Provides the name of the application as defined in the Bundle.
    */
   internal static let appName: String = {
      Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "(not set)"
   }()
   /**
    * Provides the unique identifier of the application as defined in the Bundle.
    */
   internal static let appIdentifier: String = {
      Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? "(not set)"
   }()
   /**
    * Provides the version of the application as defined in the Bundle.
    */
   internal static let appVersion: String = {
      Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "(not set)"
   }()
   /**
    * Provides the build number of the application as defined in the Bundle.
    */
   internal static let appBuild: String = {
      Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? "(not set)"
   }()
   /**
    * Provides a formatted string containing both the version and build number of the application.
    */
   internal static let formattedVersion: String = {
      "\(appVersion) (\(appBuild))"
   }()
   /**
    * Provides the preferred language of the user as defined in the system settings.
    * TODO: Consider handling different language formats (e.g., en-US, en-GB).
    */
   internal static let userLanguage: String = {
      guard let locale: String = Locale.preferredLanguages.first, !locale.isEmpty else {
         return "(not set)"
      }
      return locale
   }()
   /**
    * Provides the screen resolution of the user's device.
    * - Fixme: ⚠️️ for swift 6.0 we will need to fence UIScreen in serlialized main thread. Check with copilot etc
    */
   internal static var screenResolution: String {
      // Check if the operating system is iOS
      #if os(iOS)
      // Get the size of the screen in native points
      let size = UIScreen.main.nativeBounds.size
      // If the operating system is macOS
      #elseif os(macOS)
      // Get the size of the main screen, or use zero size if the main screen is not available
      let size = NSScreen.main?.frame.size ?? .zero
      #endif
      // Return the screen resolution as a string in the format "width x height"
      return "\(size.width)x\(size.height)"
   }
}
