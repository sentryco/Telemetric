import Foundation

public protocol TelemetricKind {
   var collector: EventCollector { get }
}
extension TelemetricKind {
   public func send(event: Event) {
      collector.trackEvent(event)
   }
}
