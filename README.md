# Geofencing DSLink

A DSLink for checking circular geofences against coordinates.

## Usage

```
pub get
dart bin/run.dart
```

Run the `Create Geofence` action with the latitude, longitude, and radius (in kilometers) of the geofence you want to check against.
Whenever you receive a location update from another source, call the `Update` action on the geofence node with the latitude and longitude. The `Is Inside` node will be updated accordingly.
