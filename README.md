# Telemetric
Telemetric for GA4

### Description:
This approach requires manual handling of the GA4 measurement protocol, which can be more complex but allows you to avoid using the Firebase SDK.

### Gotchas:
- Parameter names must be 40 characters or fewer, can only contain alpha-numeric characters and underscores, and must start with an alphabetic character.
- Parameter values must be 100 characters or fewer for standard GA4 properties and 500 characters or fewer for GA4 360 properties
- Each request can have a maximum of 25 events.
- Each event can have a maximum of 25 parameters
- User property names must be 24 characters or fewer.
- User property values must be 36 characters or fewer

### Todo:
- figure out how to use: Measurement ID: The unique identifier for your GA4 property. text tid=G-EMPR3SY5D5