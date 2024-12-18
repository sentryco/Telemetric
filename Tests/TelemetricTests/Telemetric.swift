import Telemetric
/**
 * ⚠️️ Discard this before push, or squash if you forget
 */
let measurementID: String = ""
/**
 * ⚠️️ Discard this before push, or squash if you forget
 */
let apiSecret: String = ""
/**
 * Telemetric class provides a shared instance for tracking events and managing event collection.
 */
public class Telemetric: TelemetricKind {
   /**
    * Shared instance of the Telemetric class.
    * - Note: Provides a centralized point for tracking events and managing event collection.
    */
   static let shared: Telemetric = .init()
   /**
    * Unique identifier for the user, stored in the keychain.
    */
   static let id = Identity.uniqueUserIdentifier(type: .keychain)
   /**
    * Tracker instance for sending events to the analytics service.
    * - Note: Initialized with measurement ID, API secret, and unique user identifier.
    */
   let tracker = Tracker(measurementID: measurementID, apiSecret: apiSecret, clientID: id)
   /**
    * Event collector instance for batching and sending events.
    * - Note: Initialized with a batch size of 4 and a maximum age of 5 seconds.
    * - Note: Sends collected events using the tracker instance.
    */
   public lazy var collector = EventCollector(batchSize: 4, maxAgeSeconds: 5) { events in
      self.tracker.sendEvent(events: events)
   }
}
