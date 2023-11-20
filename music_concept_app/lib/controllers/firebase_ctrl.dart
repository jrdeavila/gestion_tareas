import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class FirebaseCtrl extends GetxController {
  final List<FirebaseApp> _apps;

  FirebaseCtrl(this._apps);

  late final Rx<FirebaseApp> _defaultApp = Rx<FirebaseApp>(_apps.first);

  FirebaseApp get defaultApp => _defaultApp.value;

  List<FirebaseApp> get apps => _apps;

  @override
  void onReady() {
    super.onReady();
    _mountControllers(defaultApp);
  }

  FirebaseApp nextApp() {
    final index = _apps.indexOf(defaultApp);
    final nextIndex = index + 1;
    final nextApp = _apps[nextIndex == _apps.length ? 0 : nextIndex];
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
    Get.put(AuthenticationCtrl(app));
    Get.put(ConnectionCtrl());
    Get.put(LocationCtrl());
    Get.put(ActivityCtrl(app));
    WidgetsBinding.instance.addObserver(LifeCycleObserver(app));
  }

  void changeApp() {
    _deleteControllers();

    final app = nextApp();
    _defaultApp.value = app;
    // _changeDefaultName(app.name);

    _mountControllers(app);
  }
}
