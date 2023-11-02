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
    FirebaseAuth.instance.userChanges().listen((user) {
      _user.value =
          user != null ? UserAccountService.getUserAccountRef(user.uid) : null;
    });
  }
}
