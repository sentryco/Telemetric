import Foundation

public protocol TelemetricKind {
   var collector: EventCollector { get }
}
extension TelemetricKind {
   /**
    * Bulk
    */
   public func send(event: Event) {
      collector.trackEvent(event)
   }
   /**
    * Bulk
    */
   public func send(events: [Event]) {
      events.forEach {
         send(event: $0)
      }
   }
}
