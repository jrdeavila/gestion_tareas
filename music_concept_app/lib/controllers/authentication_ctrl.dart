import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:music_concept_app/lib.dart';

class AuthenticationCtrl extends GetxController {
  final Rx<User?> _firebaseUser = Rx<User?>(null);
  final _getStorage = GetStorage();

  @override
  void onReady() {
    super.onReady();
    _firebaseUser.listen((p0) {
      if (p0 != null) {
        Get.put(NotificationCtrl());
        Get.put(BusinessNearlyCtrl());
        Get.lazyPut(() => HomeCtrl());
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
    _firebaseUser.bindStream(FirebaseAuth.instance.authStateChanges());
  }

  void login({
    required String email,
    required String password,
  }) {
    FirebaseAuth.instance.signInWithEmailAndPassword(
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
    );
    _getStorage.write('first-login', true);
  }

  void resetPassword({
    required String email,
  }) {
    FirebaseAuth.instance.sendPasswordResetEmail(
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
    FirebaseAuth.instance.signOut();
  }
}
