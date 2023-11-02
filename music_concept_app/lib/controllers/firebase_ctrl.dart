import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:music_concept_app/lib.dart';

class FirebaseCtrl extends GetxController {
  final List<FirebaseApp> _apps;
  final GetStorage _getStorage = GetStorage();

  FirebaseCtrl(this._apps);
  FirebaseApp get defaultApp => _apps.firstWhere(
        (element) => element.name == _getStorage.read("firebase-app"),
        orElse: () => _apps.first,
      );

  List<FirebaseApp> get apps => _apps;

  @override
  void onReady() {
    super.onReady();
    Get.put(AuthenticationCtrl(defaultApp));
    Get.put(ConnectionCtrl());
    Get.put(LocationCtrl());
    Get.put(ActivityCtrl(defaultApp));

    WidgetsBinding.instance.addObserver(LifeCycleObserver(defaultApp));
  }

  void _changeDefaultName(String value) {
    _getStorage.write("firebase-app", value);
  }

  FirebaseApp nextApp() {
    final indexApp = _apps.indexOf(defaultApp);

    final nextApp =
        indexApp + 1 == _apps.length ? _apps.first : _apps[indexApp + 1];

    return nextApp;
  }

  void _deleteControllers() {
    Get.delete<AuthenticationCtrl>();
    Get.delete<ConnectionCtrl>();
    Get.delete<LocationCtrl>();
    Get.delete<ActivityCtrl>();
    Get.delete<UserCtrl>();
    Get.delete<HomeCtrl>();
    Get.delete<NotificationCtrl>();
    Get.delete<BusinessNearlyCtrl>();
    Get.delete<HomeCtrl>();
    WidgetsBinding.instance.removeObserver(LifeCycleObserver(defaultApp));
  }

  void _mountControllers(FirebaseApp app) {
    Get.put(AuthenticationCtrl(nextApp()));
    Get.put(ConnectionCtrl());
    Get.put(LocationCtrl());
    Get.put(ActivityCtrl(app));
    WidgetsBinding.instance.addObserver(LifeCycleObserver(app));
  }

  void changeApp() {
    _deleteControllers();

    final app = nextApp();
    _changeDefaultName(app.name);

    _mountControllers(app);
  }

  void changeDefaultApp(String name) {
    _deleteControllers();
    _changeDefaultName(name);
    final app = defaultApp;
    _mountControllers(app);
  }
}
