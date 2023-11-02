import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class GeolocationUtils {
  static String distanceBetweenString(double startLatitude,
      double startLongitude, double endLatitude, double endLongitude) {
    final distance = Geolocator.distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(2)} km';
    }
  }

  static void navigateToMaps(double latitude, double longitude) {
    // Ir en modo de navegacion
    final uri = Uri.parse("google.navigation:q=$latitude,$longitude");
    launchUrl(uri);
  }

  static Polygon getRadiusAbovePoint({
    String id = "radius",
    Color? color,
    required LatLng center,
    required double radius,
    int points = 360,
  }) {
    final meters = radius / 100000;
    final List<LatLng> circlePoints = [];
    for (int i = 0; i < points; i++) {
      double angle = 2 * pi * i / points;
      double x = center.latitude + meters * cos(angle);
      double y = center.longitude + meters * sin(angle);
      circlePoints.add(LatLng(x, y));
    }

    return Polygon(
      polygonId: PolygonId(id),
      points: circlePoints,
      strokeWidth: 2,
      strokeColor: color ?? Get.theme.colorScheme.primary,
      fillColor: (color ?? Get.theme.colorScheme.primary).withOpacity(0.2),
    );
  }
}
