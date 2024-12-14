import Foundation
import Combine
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
/**
 * Event Collector class
 * - Note: Batch sends events when bathsize is full
 * - Note: Batch sends events on interval when elapsed time is reached, regardless of batchsize
 * - Note: Batch sends events when iOS apps enters background and before a macOS app closes (as macOS apps doesnt have a background state)
 * - Fixme: ⚠️️ potentiallyy also add elapsed time persistence in userdefault? requires handling our own timer and storing events in userdefault. so less optimal
 */
public class EventCollector {
   #if os(iOS)
   // This line declares a variable backgroundTask of type UIBackgroundTaskIdentifier and initializes it with the value .invalid. This is the default state, indicating that no background task is currently running.
   var backgroundTask: UIBackgroundTaskIdentifier = .invalid
   #endif
   private var events: [Event] = []
   private var cancellables = Set<AnyCancellable>()
   private let eventPublisher = PassthroughSubject<Event, Never>()
   private let batchSize: Int
   private let maxAgeSeconds: Double // 24 hours = (86400)
   private let onSend: ((_ event: [Event]) -> Void)?
   /**
    * Initiate event collector
    * - Parameters:
    *   - batchSize: event threshold
    *   - maxAgeSeconds: maxTime interval
    *   - onSend: callback for sending the event
    */
   public init(batchSize: Int = 8, maxAgeSeconds: Double = 24 * 60 * 60, onSend: ((_ event: [Event]) -> Void)?) {
      self.batchSize = batchSize
      self.maxAgeSeconds = maxAgeSeconds
      self.onSend = onSend
      setupEventCollection()
      observeAppLifecycle()
   }
   
   deinit {
      // Clean up background observer
      #if os(iOS)
      NotificationCenter.default.removeObserver(self)
      #elseif os(macOS)
      NotificationCenter.default.removeObserver(self, name: NSApplication.willTerminateNotification, object: nil)
      #endif
   }
}
/**
 * Core
 */
extension EventCollector {
   /**
    * Setup event collection
    */
   private func setupEventCollection() {
      // Collect events based on count or time
      eventPublisher
         .collect(.byTimeOrCount(DispatchQueue.global(qos: .background), .seconds(self.maxAgeSeconds), self.batchSize)) // xx hours or x events
         .sink { [weak self] collectedEvents in
            self?.sendEventsToGA4(events: collectedEvents)
         }
         .store(in: &cancellables)
      // Also send any remaining events after 24 hours if not already sent
      Timer.publish(every: maxAgeSeconds, on: .main, in: .common)
         .autoconnect()
         .sink { [weak self] _ in
            if !self!.events.isEmpty {
               self?.sendEventsToGA4(events: self!.events)
            }
         }
         .store(in: &cancellables)
   }
   /**
    * Track event
    * - Parameter event: - Fixme: ⚠️️ add doc
    */
   public func trackEvent(_ event: Event) {
      events.append(event)
      eventPublisher.send(event) // Send the event to the publisher
   }
   /**
    * Send event to GA4
    * - Parameter events: - Fixme: ⚠️️ add doc
    */
   private func sendEventsToGA4(events: [Event]) {
      self.onSend?(events)
      self.events.removeAll()
   }
}
/**
 * Background iOS
 */

extension EventCollector {
   /**
    * Observe app lifecycle for background and foreground handling
    */
   private func observeAppLifecycle() {
      #if os(iOS)
      NotificationCenter.default.addObserver(
         self,
         selector: #selector(appDidEnterBackground),
         name: UIApplication.didEnterBackgroundNotification,
         object: nil
      )
      #elseif os(macOS)
      NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate), name: NSApplication.willTerminateNotification, object: nil)
      #endif
   }
   #if os(iOS)
   /**
    * When the app enters background
    */
   @objc private func appDidEnterBackground() {
      sendEventsInTheBackground()
   }
   /**
    * - Description: In iOS, when an app is sent to the background, it has a limited amount of time to complete any ongoing tasks before it is suspended. By using beginBackgroundTask and endBackgroundTask, you can request additional time to complete tasks in the background.
    * - Note: Time Limit: The app has a limited time (usually around 3 minutes) to complete the task in the background.
    * - Note: The task must be completed within this time frame, or the app will be terminated
    * - Note: It's crucial to manage resources properly and end the task when it's completed to avoid unnecessary resource usage.
    */
   private func sendEventsInTheBackground() {
      backgroundTask = UIApplication.shared.beginBackgroundTask {
         UIApplication.shared.endBackgroundTask(self.backgroundTask)
         self.backgroundTask = .invalid
      }
      // Perform the actual work here
      if !self.events.isEmpty {
         self.sendEventsToGA4(events: self.events)
      }
      // End the background task
      UIApplication.shared.endBackgroundTask(backgroundTask)
      backgroundTask = .invalid
   }
   #elseif os(macOS)
   /**
    * Perform any necessary cleanup or save operations here
    */
   @objc func appWillTerminate() {
      if !self.events.isEmpty {
         self.sendEventsToGA4(events: self.events)
      }
   }
   #endif
}
