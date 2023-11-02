import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BackgroundService {
  static Future<void> setBackground(
      String accountRef, String? assetPath) async {
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(FirebaseFirestore.instance.doc(accountRef), {
        'background': assetPath,
      });
    });
  }
}
