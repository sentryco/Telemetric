import Foundation
/**
 * A class for tracking the start and end times of events.
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
    * A shared instance of `TimingTracker` for global access.
    */
   public static let shared: TimingTracker = .init()
   /**
    * A dictionary to keep track of the start times of events.
    * - Description: The key is the event name and the value is the start time in milliseconds since 1970.
    */
   private var trackingDict: [String: Int64] = [:]
   /**
    * - Description: Tracks the start or stop of an event and returns the elapsed time in milliseconds.
    * - Parameters:
    *   - event: The name of the event to track.
    *   - isStarting: A boolean indicating whether the event is starting or stopping.
    * - Returns: The elapsed time in milliseconds if the event is stopping, otherwise nil.
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
