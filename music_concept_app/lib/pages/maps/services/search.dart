import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:music_concept_app/lib.dart';

abstract class SearchPlacesServices {
  static Future<List<Place>> searchPlaces({
    required String value,
    required double? latitudeRef,
    required double? longitudeRef,
    required CancelToken cancelToken,
  }) {
    return _dio
        .post(
      "https://places.googleapis.com/v1/places:searchText",
      data: {
        "textQuery": value,
        "languageCode": "es",
        "maxResultCount": 10,
        if (latitudeRef != null && longitudeRef != null)
          "locationBias": {
            "circle": {
              "center": {
                "latitude": latitudeRef,
                "longitude": longitudeRef,
              },
            },
          },
      },
      options: Options(
        headers: {
          "Content-Type": "application/json",
          "X-Goog-Api-Key": AppDefaults.googleApiKeyPlaces,
          "X-Goog-FieldMask":
              "places.formattedAddress,places.displayName,places.priceLevel,places.location,places.placeId"
        },
      ),
      cancelToken: cancelToken,
    )
        .then((value) {
      if (kDebugMode) {
        print(value.data);
      }
      final response = SearchPlacesResponse.fromJson(value.data);
      return response.places;
    });
  }

  static Future<Place> searchPlaceDetails(String placeId) {
    final cancelToken = CancelToken();
    return _dio
        .get(
      'https://maps.googleapis.com/maps/api/place/details/json',
      queryParameters: {
        'place_id': placeId,
        'key': AppDefaults.googleApiKeyPlaces,
      },
      cancelToken: cancelToken,
    )
        .then(
      (value) {
        cancelToken.cancel();

        return Place(
          placeId: placeId,
          formattedAddress: value.data["result"]["formatted_address"],
          location: PlaceLocation(
            latitude: value.data["result"]["geometry"]["location"]["lat"],
            longitude: value.data["result"]["geometry"]["location"]["lng"],
          ),
          displayName: DisplayName(
            text: value.data["result"]["name"],
            languageCode: "es",
          ),
        );
      },
    );
  }

  static Future<List<Place>> searchPlaceDetailsByLatLng(LatLng latLng) async {
    var cancelToken = CancelToken();
    var response = await _dio.get(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json',
      queryParameters: {
        'location': '${latLng.latitude},${latLng.longitude}',
        'radius': 150,
        'key': AppDefaults.googleApiKeyPlaces,
      },
      cancelToken: cancelToken,
    );

    cancelToken.cancel();

    List<Place> details = [];
    for (var i in (response.data["results"] as List).getRange(1, 11)) {
      final place = await searchPlaceDetails(i["place_id"]);
      details.add(place);
    }
    return details;
  }
}

Dio _dio = Dio();
