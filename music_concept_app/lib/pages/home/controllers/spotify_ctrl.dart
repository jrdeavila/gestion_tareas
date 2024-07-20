import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class SpotifyCtrl extends GetxController {
  final FirebaseApp _app;
  final RxBool _isLogged = false.obs;
  final Rx<String?> _token = Rx(null);
  final Rx<SpotifyUserInfo?> _userInfo = Rx(null);
  final RxList<SpotifyTrack> _tracks = <SpotifyTrack>[].obs;

  SpotifyCtrl(this._app);

  bool get isLogged => _isLogged.value;
  SpotifyUserInfo get userInfo => _userInfo.value!;
  bool get hasUserImage =>
      _userInfo.value != null && _userInfo.value?.imageUrl != null;
  bool get hasUserInfo => _userInfo.value != null;
  List<SpotifyTrack> get tracks => _tracks;

  @override
  void onReady() {
    super.onReady();

    _token.bindStream(UserAccountService.getUserAccountRef(
            FirebaseAuth.instanceFor(app: _app).currentUser?.uid)
        .snapshots()
        .map((event) {
      return event.data()?['spotify_token'];
    }));

    _isLogged.bindStream(UserAccountService.getUserAccountRef(
            FirebaseAuth.instanceFor(app: _app).currentUser?.uid)
        .snapshots()
        .map((event) {
      return event.data()?['spotify_token'] != null;
    }));
    ever(_token, (token) {
      if (kDebugMode) {
        print("Token: $token");
      }
      if (token != null) {
        fetchSpotifyUserInfo();
      }
    });
  }

  void fetchSpotifyUserInfo() async {
    final info = await SpotifyService.getUserInfo(_token.value!);
    if (kDebugMode) {
      print("user: $info");
    }
    _userInfo.value = info;
  }

  void login() async {
    final token = await SpotifyService.loginWithSpotify();
    final user = FirebaseAuth.instanceFor(app: _app).currentUser;
    final ref = UserAccountService.getUserAccountRef(user?.uid);
    await ref.update({
      "spotify_token": token.accessToken,
      "spotify_refresh_token": token.refreshToken,
    });

    final tracks = await SpotifyService.getUserTracks(ref.path);
    await SpotifyService.saveTracksInUser(
      userRef: ref.path,
      tracks: tracks,
    );
  }

  Future<List<SpotifyTrack>> getRecentlyPlayedTracks([String? accountRef]) {
    final user = FirebaseAuth.instanceFor(app: _app).currentUser;
    final ref = UserAccountService.getUserAccountRef(accountRef ?? user?.uid);
    return SpotifyService.getUserTracks(ref.path).onError((error, stackTrace) {
      return [];
    }).then((value) => value);
  }

  void refreshToken() async {
    final user = FirebaseAuth.instanceFor(app: _app).currentUser;
    final ref = UserAccountService.getUserAccountRef(user?.uid);
    String? refreshToken = await ref.get().then((value) {
      return value.data()?['spotify_refresh_token'];
    });
    if (refreshToken == null) return;
    final token = await SpotifyService.refreshToken(refreshToken);
    await ref.update({
      "spotify_token": token.accessToken,
      "spotify_refresh_token": token.refreshToken,
    });
  }

  void logout() async {
    final result = await Get.bottomSheet(const SpotifyLogoutBottomSheet());
    if (result == true) {
      _logout();
    }
  }

  void _logout() async {
    final user = FirebaseAuth.instanceFor(app: _app).currentUser;
    final ref = UserAccountService.getUserAccountRef(user?.uid);

    _token.value = null;
    _userInfo.value = null;

    await ref.update({
      "spotify_token": null,
      "spotify_refresh_token": null,
    });
  }

  void loadTracksToAccount(String? path) {
    final user = FirebaseAuth.instanceFor(app: _app).currentUser;
    final ref = UserAccountService.getUserAccountRef(path ?? user?.uid);
    SpotifyService.getUserTracks(ref.path).then((value) {
      _tracks.assignAll(value);
    });
  }
}

class SpotifyLogoutBottomSheet extends StatelessWidget {
  const SpotifyLogoutBottomSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final spotifyCtrl = Get.find<SpotifyCtrl>();
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.background,
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: const EdgeInsets.all(20.0),
        child: spotifyCtrl.hasUserInfo
            ? Column(
                children: [
                  const Text(
                    "Tu cuenta de Spotify",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: spotifyCtrl.hasUserImage
                        ? NetworkImage(spotifyCtrl.userInfo.imageUrl!)
                        : null,
                    backgroundColor: Get.theme.colorScheme.primary,
                    child: spotifyCtrl.hasUserImage
                        ? null
                        : Text(spotifyCtrl.userInfo.name[0].toUpperCase()),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    spotifyCtrl.userInfo.name,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(spotifyCtrl.userInfo.email),
                  const Spacer(),
                  TextButton(
                      onPressed: () {
                        Get.back(result: true);
                      },
                      child: const Text("Cerrar sesión",
                          style: TextStyle(
                            fontSize: 16.0,
                          ))),
                ],
              )
            : const LoadingIndicator(),
      );
    });
  }
}
