import Foundation

// - Fixme: ⚠️️ format the bellow to a description in the comments

// Example usage:
//   let tracker = TimingTracker()
//   tracker.track(event: "onboarding", isStarting: true) // Start tracking
//   // Simulate some delay
//   DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//      tracker.track(event: "onboarding", isStarting: false) // Stop tracking
//   }

public class TimingTracker {
   public static let shared: TimingTracker = .init()
   
   private var trackingDict: [String: Int64] = [:]
   
   @discardableResult
   public func track(event: String, isStarting: Bool) -> Int64? {
      let currentTime = Int64(Date().timeIntervalSince1970 * 1000) // Current time in msec since 1970
      if isStarting {
         trackingDict[event] = currentTime
         #if DEBUG
         print("Tracking started for \(event)")
         #endif
         return 0
      } else {
         // Check if the event exists in the dictionary
         if let startDate = trackingDict[event] {
            let elapsedTime = currentTime - startDate
            #if DEBUG
            print("Elapsed time for \(event): \(elapsedTime) msec")
            #endif
            // Remove the entry from the dictionary
            trackingDict.removeValue(forKey: event)
            return elapsedTime
         } else {
            #if DEBUG
            print("No active tracking found for \(event) to stop.")
            #endif
            return nil
         }
      }
   }
   
}
