// To parse this JSON data, do
//
//     final searchPlacesResponse = searchPlacesResponseFromJson(jsonString);

import 'dart:convert';

SearchPlacesResponse searchPlacesResponseFromJson(String str) =>
    SearchPlacesResponse.fromJson(json.decode(str));

String searchPlacesResponseToJson(SearchPlacesResponse data) =>
    json.encode(data.toJson());

class SearchPlacesResponse {
  List<Place> places;

  SearchPlacesResponse({
    required this.places,
  });

  factory SearchPlacesResponse.fromJson(Map<String, dynamic> json) =>
      SearchPlacesResponse(
        places: json.containsKey("places")
            ? List<Place>.from(json["places"].map((x) => Place.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "places": List<dynamic>.from(places.map((x) => x.toJson())),
      };
}

class Place {
  String placeId;
  String formattedAddress;
  PlaceLocation location;
  DisplayName displayName;

  Place({
    required this.placeId,
    required this.formattedAddress,
    required this.location,
    required this.displayName,
  });

  factory Place.fromJson(Map<String, dynamic> json) => Place(
        placeId: json["id"],
        formattedAddress: json["formattedAddress"],
        location: PlaceLocation.fromJson(json["location"]),
        displayName: DisplayName.fromJson(json["displayName"]),
      );

  Map<String, dynamic> toJson() => {
        "placeId": placeId,
        "formattedAddress": formattedAddress,
        "location": location.toJson(),
        "displayName": displayName.toJson(),
      };
}

class DisplayName {
  String text;
  String languageCode;

  DisplayName({
    required this.text,
    required this.languageCode,
  });

  factory DisplayName.fromJson(Map<String, dynamic> json) => DisplayName(
        text: json["text"],
        languageCode: json["languageCode"] ?? "en",
      );

  Map<String, dynamic> toJson() => {
        "text": text,
        "languageCode": languageCode,
      };
}

class PlaceLocation {
  double latitude;
  double longitude;

  PlaceLocation({
    required this.latitude,
    required this.longitude,
  });

  factory PlaceLocation.fromJson(Map<String, dynamic> json) => PlaceLocation(
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
      };
}
