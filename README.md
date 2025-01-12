[![Tests](https://github.com/sentryco/Telemetric/actions/workflows/Tests.yml/badge.svg)](https://github.com/sentryco/Telemetric/actions/workflows/Tests.yml)
[![codebeat badge](https://codebeat.co/badges/7079731f-6d84-4a37-9713-2f29c65d1f05)](https://codebeat.co/projects/github-com-sentryco-telemetric-main)

# Telemetric

### Description:
Minimal GA4 telemetrics for iOS and macOS. 

### Problem:
Using GA4 in Swift requires the FirebaseSDK, but FirebaseInstanceID, which manages user IDs, is closed-source. This lack of transparency is concerning, especially with Apple's strict user identification rules.

### Solution:
This open-source library addresses the issue. It performs the same functions as FirebaseSDK but provides transparency. You can see how personal identification is handled and adjust it to your desired privacy level.

### Features:
- 📊 Enables bulk sending of events to Google Analytics 4
- 🗂️ Caches events and processes pings in batches to optimize resource usage
- 🔐 Provides three levels of user-id persistency: vendor, userDefault, and keychain
- 🆔 Formats the GA4 clientID with UUID and Date for unique identification 

> [!NOTE]
> Cached events are processed on a timer or when the app exits or enters background mode.

### Pre-requisite:
- Create a free analytics account on [analytics.coogle.com](analytics.coogle.com) Login with your google account
- Find your Measurement-ID: [analytics.coogle.com](analytics.coogle.com) -> admin -> data collection... -> data streams -> tap your website / app -> MeasurementID
- Find your API-Secret: [analytics.coogle.com](analytics.coogle.com) -> admin -> data collection... -> data streams -> tap your website / app -> Measurement Protocol API secrets

### Ping:
Send single or multiple pings:
```swift
let tracker = Tracker(measurementID: "G-XXXXXXXXXX", apiSecret: "YYYYYYYYYYYYYYYY")
// Track events (The modern way to track)
Event.customEvent(title: "view_item_list", key: "item_list_name", value: "Home Page"),
// Track page-views (like legacy UA in GA3)
Event.pageView(engagementTimeMSec: "2400") // Use page-view to trigger user-engagment event in GA4
```

### Batch ping:
Conserve resources by intelligently batch processing the pings when the system deems it convenient
```swift
// You make your own class with the config you want. 
class Telemetric: TelemetricKind {
   static let shared: Telemetric = .init()
   let tracker = Tracker(
      measurementID: "G-XXXXXXXXXX", // Your GA4 measurement-protocol ID
      apiSecret: "YYYYYYYYYYYYYYYY", // Your GA4 API secret
      clientID: Identity.uniqueUserIdentifier(type: .vendor) // Apples privacy friendly user id
   )
   lazy var collector = EventCollector(batchSize: 10, maxAgeSeconds: 3 * 60) { events in
      self.tracker.sendEvent(events: events)
   }
}
// This will be processed after 3 minutes
// or immediately if app closed or goes into the background
// or immediately if 8 additional events are added to the stack
Telemetric.shared.send(events: [ // bulk
   Event(name: "event3", params: ["flagging": false]),
   Event(name: "event4", params: ["fiat": 100])
])
Telemetric.shared.send(event: // single
   Event(name: "onboarding", params: ["progress": "complete"])]
)
```

### Session:
- An internal timetracker records the ellapsed time for the session name
- This is just a simple example. In a real senario, we would use the EventCollector and batch send these. The code would look more or lese the same. But we would use the Telemetric.shared.send(event:..) call instead
```swift
let tracker = Tracker(measurementID: "G-XXXXXXXXXX", apiSecret: "YYYYYYYYYYYYYYYY")
tracker.send(event: Event.session(name: "onboarding", isStarting: true)) // init session
sleep(4) // Simulates time elapsed
tracker.send(event: Event.session(name: "onboarding", isStarting: false)) // end session
```

### Exceptions: 
Use Cases for Exception Tracking
- Error Logging: Track application-level errors such as uncaught exceptions or server response errors.
- Debugging: Collect stack traces or error codes for troubleshooting.
- Crash Monitoring: Identify and categorize fatal errors that cause crashes.
```swift
let exceptionEvent = Event.exception(description: "Database unavailable", isFatal: true, userAction: "open app")
tracker.sendEvent(event: exceptionEvent)
```

> [!CAUTION]  
> Google analytics for dashboards are sometimes not very responsive, and sometimes events show up later.
 
### Swift Package Manager Installation

```swift
dependencies: [
    .package(url: "https://github.com/sentryco/Telemetric", branch: "main")
]
```

> [!NOTE]
> 3 levels of userID tracking:  
> **vendor:**  Persistent between runs (in most cases)   
> **userDefault:** Persistent between runs  
> **keychain:** Persistent between installs  

### The Google Analytics 4 (GA4) Measurement Protocol

Send various types of data to GA4 via the endpoint `https://www.google-analytics.com/mp/collect`. Here are the main types of data you can send:

1. **Event Data**: 
   - You can send user interaction events, such as button clicks, page views, or transactions. Each event can include parameters that provide additional context.

2. **User Properties**: 
   - Custom user properties can be sent to define characteristics of users, such as demographics or preferences.

3. **E-commerce Data**: 
   - This includes transaction details, product impressions, and purchase events. You can send information about products, including IDs, names, categories, and prices.

4. **Session Data**: 
   - Information about user sessions can be sent to track session duration and engagement metrics.

5. **App-specific Data**: 
   - For mobile apps, you can send app usage data, including screen views and app installs.

6. **Custom Dimensions and Metrics**: 
   - You can define and send custom dimensions and metrics that are specific to your business needs.

7. **Debugging Information**: 
   - When testing your implementation, you can send debugging information to help troubleshoot issues.

8. **IP Anonymization**: 
   - You can control IP anonymization settings when sending data to comply with privacy regulations.

## Important Considerations

- **Payload Structure**: The data must be structured in a specific JSON format according to GA4's requirements.
- **Authentication**: Ensure that the requests are authenticated properly if required by your implementation.
- **Rate Limits**: Be aware of any rate limits imposed by Google Analytics for data collection.

By utilizing these various data types effectively, you can gain comprehensive insights into user behavior and interactions on your platforms.

> [!IMPORTANT]  
> For GA4 properties, IP anonymization is always enabled. This means that the last octet of IPv4 user IP addresses and the last 80 bits of IPv6 addresses are set to zeros before any data storage or processing takes place.

### Gotchas:
- The post body of the request must be smaller than 130kB
- Each request can have a maximum of 25 events.  100 (GA4 360)
- Each event can have a maximum of 25 parameters 100 (GA4 360)
- Parameter names must be 40 characters or fewer, can only contain alpha-numeric characters and underscores, and must start with an alphabetical character.
- Parameter values must be 100 characters or fewer for standard GA4 properties and 500 characters or fewer for GA4 360 properties
- User property names must be 24 characters or fewer.
- User property values must be 36 characters or fewer
- Append  "debug_mode": 1, // or "debug_mode": true to event params to use GA4 Debugging Information
- Append "session_id": "1664522264" to params and "timestamp_micros": "1664522406546590", to payload to work with session data 

> [!CAUTION]  
> Nested params in event is not supported by GA4. Use flat structures.
 
### Resources:
- Seems to have ways of using the GA4 directly (sort of like the old UA api): https://www.thyngster.com/app-web-google-analytics-measurement-protocol-version-2
- ga4 endpoint: https://www.google-analytics.com/g/collect
- Debug endpoint: https://www.google-analytics.com/debug/mp/collect

> [!WARNING]
> Ensure that the user property you are trying to send has been properly registered in GA4. You need to create the user property in the GA4 Admin section under Custom Definitions before it can be sent with events. Go to GA4 Admin. Under the "Data display" section, click on "Custom definitions"

### Todo:
- Figure out how to use: Measurement ID: The unique identifier for your GA4 property. text tid=G-EMPR3SY5D5
- Add support for user_id (track user across devices and apps)
- Figure out how to inject apikey and ma-id from github secrets, so that unit-tests works
- make an assert to make sure posts are less than max allowed at 130kB
- Remove TimingTracker, I dont think we need it