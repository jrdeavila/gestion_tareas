import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class UserCtrl extends GetxController {
  final Rx<DocumentReference<Map<String, dynamic>>?> _user =
      Rx<DocumentReference<Map<String, dynamic>>?>(null);

  DocumentReference<Map<String, dynamic>>? get user => _user.value;

  @override
  void onReady() {
    super.onReady();
    FirebaseAuth.instanceFor(app: Get.find<FirebaseCtrl>().defaultApp)
        .userChanges()
        .listen((user) {
      _user.value =
          user != null ? UserAccountService.getUserAccountRef(user.uid) : null;
    });
  }

  List<FirebaseAuth> authInstances() {
    return Get.find<FirebaseCtrl>().apps.map((e) {
      return FirebaseAuth.instanceFor(app: e);
    }).toList();
  }

  Map<String?, DocumentReference<Map<String, dynamic>>> get userAccounts {
    final data = {
      for (var e in authInstances())
        e.app.name: e.currentUser != null
            ? UserAccountService.getUserAccountRef(e.currentUser?.uid)
            : null
    }..removeWhere((key, value) => value == null);

    return data.cast();
  }

  void addAccount() {
    Get.find<FirebaseCtrl>().changeApp();
    Get.toNamed(AppRoutes.login);
  }

  void changeAccount(String name) {
    Get.find<FirebaseCtrl>().changeDefaultApp(name);
  }
}
