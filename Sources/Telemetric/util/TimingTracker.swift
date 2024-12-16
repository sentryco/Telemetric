import Foundation
/**
 * - Fixme: ⚠️️ Add doc
 * ## Examples:
 * let tracker = TimingTracker()
 * tracker.track(event: "onboarding", isStarting: true) // Start tracking
 * // Simulate some delay
 * DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
 *    tracker.track(event: "onboarding", isStarting: false) // Stop tracking
 * }
 */
public class TimingTracker {
   /**
    * - Fixme: ⚠️️ Add doc
    */
   public static let shared: TimingTracker = .init()
   /**
    * - Fixme: ⚠️️ Add doc
    */
   private var trackingDict: [String: Int64] = [:]
   /**
    * - Fixme: ⚠️️ Add doc
    */
   @discardableResult
   public func track(event: String, isStarting: Bool) -> Int64? {
      let currentTime = Int64(Date().timeIntervalSince1970 * 1000) // Current time in msec since 1970
      if isStarting {
         trackingDict[event] = currentTime
         #if DEBUG
         if isDebugging { print("Tracking started for \(event)") }
         #endif
         return 0
      } else {
         // Check if the event exists in the dictionary
         if let startDate = trackingDict[event] {
            let elapsedTime = currentTime - startDate
            #if DEBUG
            if isDebugging { print("Elapsed time for \(event): \(elapsedTime) msec") }
            #endif
            // Remove the entry from the dictionary
            trackingDict.removeValue(forKey: event)
            return elapsedTime
         } else {
            #if DEBUG
            if isDebugging { print("No active tracking found for \(event) to stop.") }
            #endif
            return nil
         }
      }
   }
}
