import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:music_concept_app/lib.dart';

abstract class SearchPlacesServices {
  static Future<List<Prediction>> searchPlaces({
    required String value,
    required CancelToken cancelToken,
  }) {
    return _dio
        .get(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json',
      queryParameters: {
        'input': value,
        'key': AppDefaults.googleApiKeyPlaces,
      },
      cancelToken: cancelToken,
    )
        .then((value) {
      return (value.data['predictions'] as List)
          .map((e) => Prediction.fromJson(e))
          .toList();
    });
  }

  static Future<PlaceDetails> searchPlaceDetails(String placeId) {
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
        return PlaceDetails.fromJson(value.data);
      },
    );
  }

  static Future<List<PlaceDetails>> searchPlaceDetailsByLatLng(
      LatLng latLng) async {
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

    List<PlaceDetails> details = [];
    for (var i in (response.data["results"] as List).getRange(1, 11)) {
      final placeDetails = await searchPlaceDetails(i["place_id"]);
      details.add(placeDetails);
    }
    return details;
  }
}

Dio _dio = Dio();
