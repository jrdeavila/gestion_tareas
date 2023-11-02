import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:music_concept_app/lib.dart';

class AuthenticationCtrl extends GetxController {
  final FirebaseApp _app;

  AuthenticationCtrl(this._app);
  final Rx<User?> _firebaseUser = Rx<User?>(null);
  final _getStorage = GetStorage();

  @override
  void onReady() {
    super.onReady();
    _firebaseUser.listen((p0) {
      if (p0 != null) {
        final app = Get.find<FirebaseCtrl>().defaultApp;
        Get.put(NotificationCtrl(app));
        Get.put(BusinessNearlyCtrl(app));
        Get.put(UserCtrl());
        Get.lazyPut(() => HomeCtrl(app));
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.delete<NotificationCtrl>();
        Get.delete<BusinessNearlyCtrl>();
        Get.delete<HomeCtrl>();
        if (_getStorage.read('first-login') == null) {
          Get.offAllNamed(AppRoutes.root);
        } else {
          Get.offAllNamed(AppRoutes.login);
        }
      }
    });
    _firebaseUser
        .bindStream(FirebaseAuth.instanceFor(app: _app).authStateChanges());
  }

  void _validateOtherApps() {
    final hasActiveAccounts = {
      for (var e in Get.find<FirebaseCtrl>().apps)
        e.name: FirebaseAuth.instanceFor(app: e).currentUser,
    }.values.any((element) => element != null);

    if (hasActiveAccounts) {
      Get.find<FirebaseCtrl>().changeApp();
    }
  }

  void login({
    required String email,
    required String password,
  }) {
    FirebaseAuth.instanceFor(app: _app).signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    _getStorage.write('first-login', true);
  }

  void register({
    required String email,
    required String password,
    required String name,
    required Uint8List? image,
    String category = "Personas",
    LatLng? location,
    String? address,
    UserAccountType type = UserAccountType.user,
  }) async {
    await UserAccountService.createAccount(
      name: name,
      email: email,
      password: password,
      image: image,
      category: category,
      type: type,
      location: location,
      address: address,
      firebaseApp: _app,
    );
    _getStorage.write('first-login', true);
  }

  void resetPassword({
    required String email,
  }) {
    FirebaseAuth.instanceFor(app: _app).sendPasswordResetEmail(
      email: email,
    );
  }

  void logout() {
    UserAccountService.saveActiveStatus(
      _firebaseUser.value!.uid,
      active: false,
    );
    BusinessService.setCurrentVisit(
      accountRef: "users/${_firebaseUser.value!.uid}",
      businessRef: null,
    );
    FirebaseAuth.instanceFor(app: _app)
        .signOut()
        .then((value) => _validateOtherApps());
  }
}
