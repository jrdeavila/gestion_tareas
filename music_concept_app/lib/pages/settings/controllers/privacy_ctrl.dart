import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class PrivacyCtrl extends GetxController {
  // --------------------------------------------------------------------------

  final FirebaseApp _app;

  PrivacyCtrl(this._app);

  FirebaseAuth get _authApp => FirebaseAuth.instanceFor(app: _app);

  // --------------------------------------------------------------------------

  @override
  void onReady() {
    super.onReady();
    ever(_profileAvatarVisibility, _onChangeProfileAvatarVisibility);
    _fetchProfileAvatarVisibility();
  }

  // --------------------------------------------------------------------------

  void _onChangeProfileAvatarVisibility(SettingsPrivacyView? value) {
    UserAccountService.changeProfileAvatarVisibility(
      accountRef: "users/${_authApp.currentUser!.uid}",
      value: value!,
    );
  }

  Future<void> _fetchProfileAvatarVisibility() async {
    final value = await UserAccountService.getProfileAvatarVisibility(
      "users/${_authApp.currentUser!.uid}",
    );
    _profileAvatarVisibility.value = value;
  }

  // --------------------------------------------------------------------------

  final Rx<SettingsPrivacyView?> _profileAvatarVisibility =
      Rx<SettingsPrivacyView?>(null);

  // --------------------------------------------------------------------------

  SettingsPrivacyView? get profileAvatarVisibility =>
      _profileAvatarVisibility.value;

  // --------------------------------------------------------------------------

  void changeProfileAvatarVisibility(SettingsPrivacyView? value) {
    _profileAvatarVisibility.value = value;
  }

  // --------------------------------------------------------------------------
}
