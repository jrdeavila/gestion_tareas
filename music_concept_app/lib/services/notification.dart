import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_concept_app/lib.dart';

abstract class NotificationService {
  static Future<void> sendNotification(
      {required String title,
      required String body,
      required String accountRef,
      required NotificationType type,
      Map<String, dynamic>? arguments}) async {
    var snapshot = await FirebaseFirestore.instance.doc(accountRef).get();
    if (!snapshot.exists) {
      throw MessageException("No existe el usuario al que quieres notificar");
    }
    await snapshot.reference.collection("notifications").add({
      "title": title,
      "body": body,
      "type": type.index,
      "arguments": arguments,
      "createdAt": FieldValue.serverTimestamp(),
      "read": false,
    });
  }

  static Future<void> sendMultipleNotifications(
      {required String title,
      required String body,
      required List<String> accountRefs,
      required NotificationType type,
      Map<String, dynamic>? arguments}) {
    return Future.wait(
      accountRefs.map(
        (e) => sendNotification(
            title: title,
            body: body,
            accountRef: e,
            type: type,
            arguments: arguments),
      ),
    );
  }

  static Future<void> deleteNotification({required String notificationRef}) {
    return FirebaseFirestore.instance.doc(notificationRef).delete();
  }

  static Future<void> deleteAllNotification({
    required String accountRef,
  }) {
    return FirebaseFirestore.instance
        .doc(accountRef)
        .collection("notifications")
        .get()
        .then((value) {
      for (var item in value.docs) {
        item.reference.delete();
      }
    });
  }

  static markAllAsRead({required String accountRef}) {
    return FirebaseFirestore.instance
        .doc(accountRef)
        .collection("notifications")
        .where("read", isEqualTo: false)
        .get()
        .then((value) {
      for (var item in value.docs) {
        item.reference.update({"read": true});
      }
    });
  }

  static Future<void> markAsRead({required String notificationRef}) {
    return FirebaseFirestore.instance
        .doc(notificationRef)
        .update({"read": true});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> notifications(
      {required String accountRef}) {
    return FirebaseFirestore.instance
        .doc(accountRef)
        .collection("notifications")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }
}

enum NotificationType {
  post,
  event,
  survey,
  info,
  like,
  comment,
}
