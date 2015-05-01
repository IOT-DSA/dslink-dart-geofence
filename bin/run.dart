import "dart:math";

import "package:dslink/client.dart";
import "package:dslink/responder.dart";
import "package:dslink/common.dart";

import "package:dslink_geofence/geofence.dart";
import "package:dslink/utils.dart" show Base64;

LinkProvider link;

main(List<String> args) async {

  link = new LinkProvider(
    args,
    "Geofence-",
    isRequester: true,
    isResponder: true,
    defaultNodes: {
      "Add Geofence": {
        r"$is": "addGeofence",
        r"$invokable": "write",
        r"$result": "values",
        r"$params": [
          {
            "name": "name",
            "type": "string"
          },
          {
            "name": "latitude",
            "type": "number"
          },
          {
            "name": "longitude",
            "type": "number"
          },
          {
            "name": "radius",
            "type": "number"
          }
        ],
        r"$columns": [
          {
            "name": "success",
            "type": "bool"
          }
        ]
      }
    },
    profiles: {
      "addGeofence": (String path) => new AddGeofenceNode(path),
      "updateLocation": (String path) => new UpdateLocationNode(path),
      "deleteGeofence": (String path) => new DeleteGeofenceNode(path)
    }
  );

  link.connect();
}

class AddGeofenceNode extends SimpleNode {
  AddGeofenceNode(String path) : super(path);

  @override
  onInvoke(Map<String, dynamic> params) {
    var name = params["name"];
    var lat = params["latitude"];
    var lng = params["longitude"];
    var radius = params["radius"];

    if (name == null || lat == null || lng == null || radius == null) return {
      "success": false
    };

    var map = {
      r"$name": name
    };

    map["Inside"] = {
      r"$name": "Is Inside",
      r"$type": "bool",
      "?value": false
    };

    map["Radius"] = {
      r"$type": "number",
      "?value": radius
    };

    map["Center_Latitude"] = {
      r"$name": "Center Latitude",
      r"$type": "number",
      "?value": lat
    };

    map["Center_Longitude"] = {
      r"$name": "Center Longitude",
      r"$type": "number",
      "?value": lng
    };

    map["Update"] = {
      r"$is": "updateLocation",
      r"$invokable": "write",
      r"$result": "values",
      r"$params": [
        {
          "name": "latitude",
          "type": "number"
        },
        {
          "name": "longitude",
          "type": "number"
        }
      ]
    };

    map["Delete"] = {
      r"$is": "deleteGeofence",
      r"$invokable": "write"
    };

    var n = Base64.encode(name.codeUnits);

    link.addNode("/${n}", map);

    link.save();

    return {
      "success": true
    };
  }
}

class UpdateLocationNode extends SimpleNode {
  UpdateLocationNode(String path) : super(path);

  @override
  onInvoke(Map<String, dynamic> params) {
    var latitude = params["latitude"];
    var longitude = params["longitude"];

    if (latitude == null || longitude == null) return {
      "success": false
    };

    var location = new Location(latitude, longitude);

    var p = path.split("/");
    p.removeLast();
    p = p.join("/");

    print(p + "/Center_Latitude");

    var ml = link[p + "/Center_Latitude"].lastValueUpdate.value;
    var mn = link[p + "/Center_Longitude"].lastValueUpdate.value;
    var r = link[p+ "/Radius"].lastValueUpdate.value;

    print("CENTER: (${ml}, ${mn}), RADIUS(${r})");
    print("TO(${location.latitude}, ${location.longitude})");

    var dist = location.distanceBetweenInKm(new Location(ml, mn));

    link[p + "/Inside"].updateValue(dist <= r);

    return {};
  }
}

class DeleteGeofenceNode extends SimpleNode {
  DeleteGeofenceNode(String path) : super(path);

  @override
  onInvoke(Map<String, dynamic> params) {
    var parent = new Path(path).parentPath;
    link.provider.removeNode(parent);
    return {};
  }
}

List<Point<int>> parseGeofence(String input) {
  var parts = input.split("|").map((it) => it.trim()).toList();

  if (parts.length < 3) {
    return null;
  }

  var p = [];

  for (var x in parts) {
    var l = x.split(",").map((it) => it.trim()).toList();
    if (l.length != 2) {
      continue;
    }

    var lat = num.parse(l[0], (a) => null);
    var lng = num.parse(l[1], (a) => null);

    if (lat == null || lng == null) {
      continue;
    }

    p.add(new Point(lat, lng));
  }

  if (p.length < 3) {
    return null;
  }

  return p;
}
