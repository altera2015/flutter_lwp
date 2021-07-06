# API

A more complete example can be found in the example subdirectory. A quick overview
is provided below.

## Getting Started

Using this library involves a few steps.

1. Initialize the IHubScanner

The factory method abstracts any platform dependent backend
from your code. Currently it only supports iOS and Android.

```dart
final IHubScanner scanner = IHubScanner.factory();
```

2. Register for Hub Notifications

This is the mechanism to get notified when a hub is added or 
removed from the hubList.

```dart
scanner.stream.listen((HubList hubList) async {
  if (hubList.length < 0) {
    return;
  }
  bool success = await hub[0].connect();
  // implemented a bit further down.
  newHubFound(hub);
```


3. Start Scanning for Hubs 

You'll need to tell the library to actually start looking
for hubs.

```dart
_scanner.startScanning();
```

4. Implement newHubFound(hub)

Discover all the peripherals on the hub.

```dart
void newHubFound(Hub hub) {

  hub.hubStateStream.listen((HubState state) async {
    print(state.peripherals);
    // do something with these peripherals!

  });

}
```


5. Perform an operation on peripheral

Once you have your peripherals you can make them do something!

```dart
(state.peripherals[0] as MotorPeripheral).startSpeed(100, 50, MotorAccelerationProfile.None);
```
