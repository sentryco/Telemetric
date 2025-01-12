import Foundation

/// A protocol representing a telemetry handler capable of collecting and sending events.
public protocol TelemetricKind {
   /// The event collector responsible for managing and sending events.
   var collector: EventCollector { get }
}

extension TelemetricKind {
   /**
    * Sends a single event using the event collector.
    * - Parameter event: The event to be sent.
    */
   public func send(event: Event) {
      collector.trackEvent(event)
   }

   /**
    * Sends multiple events using the event collector.
    * - Parameter events: An array of events to be sent.
    * - Note: Each event in the array is sent individually.
    */
   public func send(events: [Event]) {
      events.forEach {
         send(event: $0)
      }
   }
}
