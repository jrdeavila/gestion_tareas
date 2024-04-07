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
        .listen((user) async {
      final ref = UserAccountService.getUserAccountRef(user?.uid);
      final snapshot = await ref.get();
      if (snapshot.exists) {
        _user.value = ref;
      } else {
        _user.value = null;
      }
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
  }

  void changeAccount(String name) {
    Get.find<FirebaseCtrl>().changeApp();
  }
}
