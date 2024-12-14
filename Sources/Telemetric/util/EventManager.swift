import Foundation
#if os(iOS)
import UIKit
#endif

class EventManager {
//   static let shared = EventManager()
   
   private var events: [Event] = []
   private var timer: Timer?
   private let eventThreshold = 10
   private let maxTimeInterval: TimeInterval = 24 * 60 * 60 // 24 hours
   private var lastBackgroundTime: Date?
   
   private init() {
      startTimer()
   }
   
   // Add an event to the queue
   func addEvent(name: String, parameters: [String: Any]) {
      let event = Event(name: name, params: parameters/*, timestamp: Date()*/)
      events.append(event)
      
      if events.count >= eventThreshold {
         sendEvents()
      }
   }
   
   // Send the batched events
   private func sendEvents() {
      guard !events.isEmpty else { return }
      
      // Here, replace with actual GA4 sending logic
      print("Sending \(events.count) events to GA4.")
      events.forEach { event in
         print("Event: \(event.name), Parameters: \(event.params) ")
      }
      
      // Clear the events after sending
      events.removeAll()
   }
   
   // Timer-based sending for the 24-hour rule
   private func startTimer() {
      timer = Timer.scheduledTimer(withTimeInterval: maxTimeInterval, repeats: true) { [weak self] _ in
         self?.sendEvents()
      }
   }
   
   // Clean up timer when not needed
   deinit {
      timer?.invalidate()
      NotificationCenter.default.removeObserver(self)
   }
   
   
   // Observe app lifecycle for background and foreground handling
   private func observeAppLifecycle() {
      #if os(iOS)
      NotificationCenter.default.addObserver(
         self,
         selector: #selector(appDidEnterBackground),
         name: UIApplication.didEnterBackgroundNotification,
         object: nil
      )

      NotificationCenter.default.addObserver(
         self,
         selector: #selector(appWillEnterForeground),
         name: UIApplication.willEnterForegroundNotification,
         object: nil
      )
      #endif
   }
   
   @objc private func appDidEnterBackground() {
      lastBackgroundTime = Date()
      saveEventsToPersistentStorage()
   }
   
   @objc private func appWillEnterForeground() {
      if let lastBackgroundTime = lastBackgroundTime {
         let timeElapsed = Date().timeIntervalSince(lastBackgroundTime)
         
         // Check if the 24-hour rule has been exceeded
         if timeElapsed >= maxTimeInterval {
            sendEvents()
         }
      }
      
      loadEventsFromPersistentStorage()
   }
   
   
   private func saveEventsToPersistentStorage() {
      // Save `events` to persistent storage (e.g., UserDefaults, a file, or database)
      // Example using UserDefaults (not recommended for large data):
      let encodedData = try? JSONEncoder().encode(events)
      UserDefaults.standard.set(encodedData, forKey: "pendingEvents")
   }
   
   private func loadEventsFromPersistentStorage() {
      // Load `events` from persistent storage
      if let encodedData = UserDefaults.standard.data(forKey: "pendingEvents"),
         let savedEvents = try? JSONDecoder().decode([Event].self, from: encodedData) {
         events = savedEvents
      }
   }
}
