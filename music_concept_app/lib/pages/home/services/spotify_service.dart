import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/spotify_oauth2_client.dart';

final dioClient = Dio()
  ..interceptors.addAll([
    LogInterceptor(),
    InterceptorsWrapper(
      onError: (e, handler) {
        if (e.response?.statusCode == 401) {
          log("Refreshing token");
          Get.find<SpotifyCtrl>().refreshToken();
        }
        return handler.next(e);
      },
    )
  ]);

class SpotifyUserInfo {
  final String name;
  final String email;
  final String? imageUrl;

  SpotifyUserInfo({
    required this.name,
    required this.email,
    required this.imageUrl,
  });
}

abstract class SpotifyService {
  static Future<SpotifyUserInfo> getUserInfo(String token) async {
    final res = await dioClient.get("https://api.spotify.com/v1/me",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ));
    final name = res.data['display_name'] as String;
    final email = res.data['email'] as String;
    final imageUrl = (res.data['images'] as List).isNotEmpty
        ? res.data['images'][0]['url'] as String
        : null;
    return SpotifyUserInfo(
      name: name,
      email: email,
      imageUrl: imageUrl,
    );
  }

  static Future<AccessTokenResponse> loginWithSpotify() async {
    final client = SpotifyOAuth2Client(
      customUriScheme: "com.beatconnect.app",
      redirectUri: "com.beatconnect.app://oauth2",
    );
    final res = await client.requestAuthorization(
        clientId: "3f186983ab6e4d93a29859eee4a07bce",
        scopes: [
          'user-read-email',
          'user-read-private',
          'user-read-recently-played',
          'user-read-playback-state',
          'user-library-read',
        ]);

    final code = res.code;
    final token = await client.requestAccessToken(
      code: code.toString(),
      clientId: "3f186983ab6e4d93a29859eee4a07bce",
      clientSecret: "0d49fe39db9843fba3edb4b15c04c048",
    );
    return token;
  }

  static Future<AccessTokenResponse> refreshToken(String refreshToken) async {
    final client = SpotifyOAuth2Client(
      customUriScheme: "com.beatconnect.app",
      redirectUri: "com.beatconnect.app://oauth2",
    );

    final token = await client.refreshToken(
      refreshToken,
      clientId: "3f186983ab6e4d93a29859eee4a07bce",
      clientSecret: "0d49fe39db9843fba3edb4b15c04c048",
      scopes: [
        'user-read-email',
        'user-read-private',
        'user-read-recently-played',
        'user-read-playback-state',
        'user-library-read',
      ],
    );

    return token;
  }

  static Future<List<SpotifyTrack>> getRecentlyPlayedTracks(
      String token) async {
    final res = await dioClient.get("https://api.spotify.com/v1/me/tracks",
        queryParameters: {
          "limit": "50",
          "market": "ES",
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ));
    final tracks = res.data['items'].cast<Map<String, dynamic>>()
        as List<Map<String, dynamic>>;
    final trackModels = tracks.map((e) => SpotifyTrack.fromJson(e)).toList();
    return trackModels
        .where(
            (element) => element.name.isNotEmpty && element.artist.isNotEmpty)
        .toList()
        .sublist(0, 10);
  }

  static Future<void> saveTracksInUser({
    required String userRef,
    required List<SpotifyTrack> tracks,
  }) {
    return FirebaseFirestore.instance.doc(userRef).collection('tracks').add({
      "tracks": tracks.map((e) => e.toFirebase()).toList(),
      "createdAt": DateTime.now().toIso8601String(),
    });
  }

  static Future<List<SpotifyTrack>> getUserTracks(String userRef) {
    return FirebaseFirestore.instance
        .doc(userRef)
        .collection('tracks')
        .where("tracks", isNotEqualTo: [])
        .get()
        .then(
          (value) {
            if (value.docs.isEmpty) {
              return [];
            }

            final orderedDocs = value.docs.where((element) {
              final createdAt = element.data()['createdAt'] as String;
              final date = DateTime.parse(createdAt);
              return date
                  .isAfter(DateTime.now().subtract(const Duration(days: 1)));
            }).toList();
            orderedDocs.sort((a, b) {
              final createdAtA = a.data()['createdAt'] as String;
              final createdAtB = b.data()['createdAt'] as String;
              final dateA = DateTime.parse(createdAtA);
              final dateB = DateTime.parse(createdAtB);
              return dateA.compareTo(dateB);
            });

            final last = orderedDocs.last;

            List<SpotifyTrack> tracks = last
                .data()['tracks']
                .map<SpotifyTrack>((e) => SpotifyTrack.fromFirebase(e))
                .toList();

            return tracks;
          },
        );
  }
}
