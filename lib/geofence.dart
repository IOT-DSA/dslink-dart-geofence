import "dart:math";

class Location {
  final double latitude;
  final double longitude;

  Location(this.latitude, this.longitude);

  double distanceBetweenInKm(Location b) {
    var lat1 = latitude;
    var lon1 = longitude;
    var lat2 = b.latitude;
    var lon2 = b.longitude;

    var R = 6378.16; // Radius of the earth in km
    var dLat = deg2rad(lat2 - lat1);  // deg2rad below
    var dLon = deg2rad(lon2 - lon1);
    var a = sin(dLat / 2) * sin(dLat / 2) + cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = R * c;
    return d;
  }
}

double deg2rad(double deg) {
  return deg * (PI / 180);
}
