import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class LifeCycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      Get.find<ActivityCtrl>().resetTimer();
    }
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      UserAccountService.saveActiveStatus(
        FirebaseAuth.instance.currentUser!.uid,
        active: false,
      );
      UserAccountService.saveActiveStatus(
        FirebaseAuth.instance.currentUser!.uid,
        active: false,
      );
      BusinessService.setCurrentVisit(
          accountRef: "users/${FirebaseAuth.instance.currentUser!.uid}");
    }
  }
}

class ActivityCtrl extends GetxController {
  Timer? _timer;
  final _duration = 1.minutes;
  final RxBool _authenticated = RxBool(false);

  @override
  void onReady() {
    super.onReady();
    _authenticated.bindStream(
        FirebaseAuth.instance.userChanges().map((event) => event != null));
    _authenticated.listen((event) {
      if (event) {
        resetTimer();
      }
    });
  }

  void _sendInactivityState([bool status = true]) {
    UserAccountService.saveActiveStatus(
      FirebaseAuth.instance.currentUser!.uid,
      active: status,
    );
  }

  void resetTimer() {
    if (!_authenticated.value) {
      return;
    }
    _sendInactivityState();
    _timer?.cancel();
    _timer = Timer(_duration, () {
      _sendInactivityState(false);
    });
  }
}
