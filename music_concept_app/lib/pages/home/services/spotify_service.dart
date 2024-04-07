import 'package:oauth2_client/spotify_oauth2_client.dart';

abstract class SpotifyService {
  static Future<String> loginWithSpotify() async {
    final client = SpotifyOAuth2Client(
      customUriScheme: "com.beatconnect.app",
      redirectUri: "com.beatconnect.app://oauth2",
    );
    final res = await client.requestAuthorization(
        clientId: "3f186983ab6e4d93a29859eee4a07bce",
        scopes: [
          'user-read-private',
          'user-read-playback-state',
          'user-modify-playback-state',
          'user-read-currently-playing',
          'user-read-email'
        ]);
    final code = res.code;
    final token = await client.requestAccessToken(
      code: code.toString(),
      clientId: "3f186983ab6e4d93a29859eee4a07bce",
      clientSecret: "0d49fe39db9843fba3edb4b15c04c048",
    );
    return token.accessToken.toString();
  }
}
