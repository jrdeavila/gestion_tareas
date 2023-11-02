import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class NotificationCtrl extends GetxController {
  final FirebaseApp _app;

  NotificationCtrl(this._app);

  FirebaseAuth get _authApp => FirebaseAuth.instanceFor(app: _app);

  final RxInt _notificationCount = RxInt(0);
  final RxList<FdSnapshot> _notifications = RxList<FdSnapshot>([]);
  int get notificationCount => _notificationCount.value;

  List<FdSnapshot> get notifications => _notifications;

  @override
  void onReady() {
    super.onReady();

    _notifications.bindStream(
      NotificationService.notifications(
        accountRef: "users/${_authApp.currentUser?.uid}",
      ).map((event) => event.docs),
    );
    ever(_notifications, _onNotificationChange);
  }

  void _onNotificationChange(List<FdSnapshot> notifications) {
    if (notifications.isNotEmpty &&
        notifications.first.data()?["read"] == false) {
      var last = notifications.first;
      AudioPlayer().play(AssetSource("notification/notification.mp3"));
      SnackbarUtils.showBanner(
        icon: notificationIcon[last.data()?["type"]]!.icon,
        title: last["title"],
        message: last["body"],
        label: "",
      );
    }

    _notificationCount.value = notifications
        .where((element) => element.data()?["read"] == false)
        .length;
  }

  void deleteNotification(String notificationRef) {
    NotificationService.deleteNotification(
      notificationRef: notificationRef,
    );
  }

  void markAllAsRead() {
    NotificationService.markAllAsRead(
      accountRef: "users/${_authApp.currentUser!.uid}",
    );
  }

  void markAsRead(String notificationRef) {
    NotificationService.markAsRead(
      notificationRef: notificationRef,
    );
  }

  void deleteAll() {
    NotificationService.deleteAllNotification(
      accountRef: "users/${_authApp.currentUser!.uid}",
    );
  }
}

Map<int, Icon> notificationIcon = {
  0: Icon(MdiIcons.newspaperVariantMultipleOutline,
      color: Get.theme.colorScheme.primary, size: 30.0),
  1: Icon(MdiIcons.calendar, color: Get.theme.colorScheme.primary, size: 30.0),
  2: Icon(MdiIcons.poll, color: Get.theme.colorScheme.primary, size: 30.0),
  3: Icon(MdiIcons.information,
      color: Get.theme.colorScheme.primary, size: 30.0),
  5: Icon(MdiIcons.comment, color: Get.theme.colorScheme.onPrimary, size: 30.0),
  4: Icon(MdiIcons.heart, color: Get.theme.colorScheme.error, size: 30.0),
};
