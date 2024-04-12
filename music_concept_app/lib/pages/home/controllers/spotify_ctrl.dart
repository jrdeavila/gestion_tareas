import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class SpotifyCtrl extends GetxController {
  final FirebaseApp _app;
  final RxBool _isLogged = false.obs;

  SpotifyCtrl(this._app);

  bool get isLogged => _isLogged.value;

  @override
  void onReady() {
    super.onReady();

    _isLogged.bindStream(UserAccountService.getUserAccountRef(
            FirebaseAuth.instanceFor(app: _app).currentUser?.uid)
        .snapshots()
        .map((event) {
      return event.data()?['spotify_token'] != null;
    }));
  }

  void login() async {
    final token = await SpotifyService.loginWithSpotify();
    final user = FirebaseAuth.instanceFor(app: _app).currentUser;
    final ref = UserAccountService.getUserAccountRef(user?.uid);
    await ref.update({
      "spotify_token": token.accessToken,
      "spotify_refresh_token": token.refreshToken,
    });
  }

  Future<List<SpotifyTrack>> getRecentlyPlayedTracks() {
    final user = FirebaseAuth.instanceFor(app: _app).currentUser;
    final ref = UserAccountService.getUserAccountRef(user?.uid);
    return SpotifyService.getUserTracks(ref.path).onError((error, stackTrace) {
      return [];
    }).then((value) => value);
  }

  void refreshToken() async {
    final user = FirebaseAuth.instanceFor(app: _app).currentUser;
    final ref = UserAccountService.getUserAccountRef(user?.uid);
    final refreshToken = await ref.get().then((value) {
      return value.data()?['spotify_refresh_token'];
    });
    final token = await SpotifyService.refreshToken(refreshToken);
    await ref.update({
      "spotify_token": token.accessToken,
      "spotify_refresh_token": token.refreshToken,
    });
  }
}
