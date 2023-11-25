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
    ever(_profileStatusVisibility, _onChangeProfileStatusVisibility);
    ever(
      _profileBusinessStatusVisibility,
      _onChangeProfileBusinessStatusVisibility,
    );
    _fetchProfileAvatarVisibility();
    _fetchProfileStatusVisibility();
    _fetchProfileBusinessStatusVisibility();
  }

  // --------------------------------------------------------------------------

  void _onChangeProfileAvatarVisibility(SettingsPrivacyView? value) {
    UserAccountService.changeProfileAvatarVisibility(
      accountRef: "users/${_authApp.currentUser!.uid}",
      value: value!,
    );
  }

  void _onChangeProfileStatusVisibility(SettingsPrivacyView? value) {
    UserAccountService.changeProfileStatusVisibility(
      accountRef: "users/${_authApp.currentUser!.uid}",
      value: value!,
    );
  }

  void _onChangeProfileBusinessStatusVisibility(SettingsPrivacyView? value) {
    UserAccountService.changeProfileBusinessStatusVisibility(
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

  Future<void> _fetchProfileStatusVisibility() async {
    final value = await UserAccountService.getProfileStatusVisibility(
      "users/${_authApp.currentUser!.uid}",
    );
    _profileStatusVisibility.value = value;
  }

  Future<void> _fetchProfileBusinessStatusVisibility() async {
    final value = await UserAccountService.getProfileBusinessStatusVisibility(
      "users/${_authApp.currentUser!.uid}",
    );
    _profileBusinessStatusVisibility.value = value;
  }

  // --------------------------------------------------------------------------

  final Rx<SettingsPrivacyView?> _profileAvatarVisibility =
      Rx<SettingsPrivacyView?>(null);

  final Rx<SettingsPrivacyView?> _profileStatusVisibility =
      Rx<SettingsPrivacyView?>(null);

  final Rx<SettingsPrivacyView?> _profileBusinessStatusVisibility =
      Rx<SettingsPrivacyView?>(null);

  // --------------------------------------------------------------------------

  SettingsPrivacyView? get profileAvatarVisibility =>
      _profileAvatarVisibility.value;

  SettingsPrivacyView? get profileStatusVisibility =>
      _profileStatusVisibility.value;

  SettingsPrivacyView? get profileBusinessStatusVisibility =>
      _profileBusinessStatusVisibility.value;

  // --------------------------------------------------------------------------

  void changeProfileAvatarVisibility(SettingsPrivacyView? value) {
    _profileAvatarVisibility.value = value;
  }

  void changeProfileStatusVisibility(SettingsPrivacyView? value) {
    _profileStatusVisibility.value = value;
  }

  void changeProfileBusinessStatusVisibility(SettingsPrivacyView? p0) {
    _profileBusinessStatusVisibility.value = p0;
  }

  // --------------------------------------------------------------------------
}
