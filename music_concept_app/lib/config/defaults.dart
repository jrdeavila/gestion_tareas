import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class AppDefaults {
  static const titleName = "BeatConnect";
  static const firebaseStorageBucket = "gs://music-concept-app.appspot.com";
  static const googleApiKeyPlaces = "AIzaSyA49opAaeHWJTYkHbSy5VHUoD63Q38w3RM";
  static const defaultPositon = LatLng(
    10.4634,
    -73.2532,
  );
  static const mapStyles = """ """;

  static const firebaseAuthInstances = [
    // '[SECONDARY]',
  ];
}
