import Foundation

// - Fixme: ⚠️️ format the bellow to a description in the comments
//- I need a method in class that receives a string like "onboarding" and a bool indicating start and stop.
//- When true the method needs to store a date in msec since 1970 and store it and a UUID in a dict with key of the string the method received "onboarding"
//- When false it should calculate the elapsed time in msec since the date was stored and print the time in msec, and remove item from the dict
//- when true and the key already exists in the dict, it should override the date

// Example usage:
//   let tracker = TimingTracker()
//   tracker.track(event: "onboarding", isStarting: true) // Start tracking
//   // Simulate some delay
//   DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//      tracker.track(event: "onboarding", isStarting: false) // Stop tracking
//   }

public class TimingTracker {
   public static let shared: TimingTracker = .init()
   
   private var trackingDict: [String: (startDate: Int64, uuid: UUID)] = [:]
   
   @discardableResult
   public func track(event: String, isStarting: Bool) -> (elapsedTime: Int64, uuid: UUID)? {
      let currentTime = Int64(Date().timeIntervalSince1970 * 1000) // Current time in msec since 1970
      if isStarting {
         // Store the date and UUID in the dictionary, override if key exists
         let newUUID = UUID()
         trackingDict[event] = (startDate: currentTime, uuid: newUUID)
         #if DEBUG
         print("Tracking started for \(event). UUID: \(newUUID)")
         #endif
         return nil
      } else {
         // Check if the event exists in the dictionary
         if let entry = trackingDict[event] {
            let elapsedTime = currentTime - entry.startDate
            #if DEBUG
            print("Elapsed time for \(event): \(elapsedTime) msec")
            #endif
            // Remove the entry from the dictionary
            trackingDict.removeValue(forKey: event)
            return (elapsedTime, entry.uuid)
         } else {
            #if DEBUG
            print("No active tracking found for \(event) to stop.")
            #endif
            return nil
         }
      }
   }
   
}
