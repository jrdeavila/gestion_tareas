import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class LifeCycleObserver extends WidgetsBindingObserver {
  final FirebaseApp _app;

  LifeCycleObserver(this._app);

  FirebaseAuth get _authApp => FirebaseAuth.instanceFor(app: _app);
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      Get.find<ActivityCtrl>().resetTimer();
    }
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      UserAccountService.saveActiveStatus(
        _authApp.currentUser!.uid,
        active: false,
      );
      UserAccountService.saveActiveStatus(
        _authApp.currentUser!.uid,
        active: false,
      );
      BusinessService.setCurrentVisit(
          accountRef: "users/${_authApp.currentUser!.uid}");
    }
  }
}

class ActivityCtrl extends GetxController {
  final FirebaseApp _app;

  ActivityCtrl(this._app);

  FirebaseAuth get _authApp => FirebaseAuth.instanceFor(app: _app);

  Timer? _timer;
  final _duration = 1.minutes;
  final RxBool _authenticated = RxBool(false);

  @override
  void onReady() {
    super.onReady();
    _authenticated
        .bindStream(_authApp.userChanges().map((event) => event != null));
    _authenticated.listen((event) {
      if (event) {
        resetTimer();
      }
    });
  }

  void _sendInactivityState([bool status = true]) {
    UserAccountService.saveActiveStatus(
      _authApp.currentUser!.uid,
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
