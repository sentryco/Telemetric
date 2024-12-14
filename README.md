[![Tests](https://github.com/sentryco/Telemetric/actions/workflows/Tests.yml/badge.svg)](https://github.com/sentryco/Telemetric/actions/workflows/Tests.yml)

# Telemetric

### Description:
Minimal GA4 telemetrics for iOS and macOS. 

### Problem:
- Utilizing GA4 in Swift requires the FirebaseSDK. However, FirebaseInstanceID, responsible for handling user-ids, is closed source. This lack of transparency can be concerning, especially considering potential violations of Apple's stringent user identification rules.

### Solution:
- This open-source library offers a solution. It performs the same functions as the FirebaseSDK, but with the added benefit of transparency. You can see exactly how personal identification is handled and even adjust it to a level you're comfortable with.

### Pre-requsit:
- Create a free analytics account on [analytics.coogle.com](analytics.coogle.com) Login with your google account
- Find your Measurment-ID: [analytics.coogle.com](analytics.coogle.com) -> admin -> data collectiion... -> data streams -> tap your website / app -> MeasurmentID
- Find your API-Secret: [analytics.coogle.com](analytics.coogle.com) -> admin -> data collectiion... -> data streams -> tap your website / app -> Measurement Protocol API secrets

### Examples:

```swift
let tracker = GA4Tracker(measurementID: "G-XXXXXXXXXX", apiSecret: "YYYYYYYYYYYYYYYY")
// Track events (The modern way to track)
Event.customEvent(title: "view_item_list", key: "item_list_name", value: "Home Page"),
// Track page-views (like legacy UA in GA3)
Event.pageView(engagementTimeMSec: "2400")
```

> [!NOTE]
> 3 levels of userID tracking:  
> **vendor:**  Persistent between runs (in most cases)   
> **userDefault:** Persistent between runs  
> **keychain:** Persistent between installs   


### Swift Package Manager Installation

```swift
dependencies: [
    .package(url: "https://github.com/sentryco/telemetric", branch: "main")
]
```

> [!IMPORTANT]  
> For GA4 properties, IP anonymization is always enabled. This means that the last octet of IPv4 user IP addresses and the last 80 bits of IPv6 addresses are set to zeros before any data storage or processing takes place.

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

### Gotchas:
- Parameter names must be 40 characters or fewer, can only contain alpha-numeric characters and underscores, and must start with an alphabetic character.
- Parameter values must be 100 characters or fewer for standard GA4 properties and 500 characters or fewer for GA4 360 properties
- Each request can have a maximum of 25 events.
- Each event can have a maximum of 25 parameters
- User property names must be 24 characters or fewer.
- User property values must be 36 characters or fewer
- Append  "debug_mode": 1, // or "debug_mode": true to event params to use GA4 Debugging Information
- Append "session_id": "1664522264" to params and "timestamp_micros": "1664522406546590", to payload to work with session data 

### Resources:
- Seems to have ways of using the GA4 directly (sort of like the old UA api): https://www.thyngster.com/app-web-google-analytics-measurement-protocol-version-2
- ga4 endpoint: https://www.google-analytics.com/g/collect
- Debug endpoint: https://www.google-analytics.com/debug/mp/collect

> [!WARNING]  
> Nested params in event is not working at the moment. This will be implemented later. When the struct -> json format conversion can output clean json.
 
> [!WARNING]
> Ensure that the user property you are trying to send has been properly registered in GA4. You need to create the user property in the GA4 Admin section under Custom Definitions before it can be sent with events. Go to GA4 Admin. Under the "Data display" section, click on "Custom definitions"

### Todo:
- Figure out how to use: Measurement ID: The unique identifier for your GA4 property. text tid=G-EMPR3SY5D5
- Add support for user_id (track user across devices and apps)
- Figure out how to inject apikey and ma-id from github secrets, so that unit-tests works
