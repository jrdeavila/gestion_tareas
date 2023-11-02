import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:music_concept_app/lib.dart';

abstract class EventService {
  static Future<void> createEvent({
    String? eventRef,
    required String content,
    required LatLng point,
    required DateTime startDate,
    required String accountRef,
  }) async {
    if (eventRef != null) {
      return FirebaseFirestore.instance
          .collection("posts")
          .doc(eventRef)
          .update({
        "content": content,
        "point": GeoPoint(
          point.latitude,
          point.longitude,
        ),
        "startDate": Timestamp.fromDate(startDate),
        "updatedAt": FieldValue.serverTimestamp(),
      });
    }

    var res = await FirebaseFirestore.instance.collection("posts").add({
      "content": content,
      "point": GeoPoint(
        point.latitude,
        point.longitude,
      ),
      "visibility": PostVisibility.public.index,
      "startDate": Timestamp.fromDate(startDate),
      'createdAt': FieldValue.serverTimestamp(),
      "deletedAt": null,
      "accountRef": accountRef,
      "type": PostType.event.index,
    });
    return PostNotification.sendPostNotification(
      accountRef: accountRef,
      postRef: res.path,
      type: PostType.event,
    );
  }

  static Future<void> createEventAssist({
    required String accountRef,
    required String eventRef,
  }) async {
    final hasAssist = await FirebaseFirestore.instance
        .collection("posts")
        .doc(eventRef)
        .collection("assists")
        .where("accountRef", isEqualTo: accountRef)
        .get()
        .then((value) => value.docs.isNotEmpty);

    if (hasAssist) return;

    await FirebaseFirestore.instance
        .collection("posts")
        .doc(eventRef)
        .collection("assists")
        .add({
      "accountRef": accountRef,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteEventAssist({
    required String accountRef,
    required String eventRef,
  }) {
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      var value = await FirebaseFirestore.instance
          .collection("posts")
          .doc(eventRef)
          .collection("assists")
          .where("accountRef", isEqualTo: accountRef)
          .get();
      await Future.wait(
          value.docs.map((element) => element.reference.delete()));
      return;
    });
  }

  static Stream<bool> hasAssistOnEvent({
    required String accountRef,
    required String eventRef,
  }) {
    return FirebaseFirestore.instance
        .collection("posts")
        .doc(eventRef)
        .collection("assists")
        .where("accountRef", isEqualTo: accountRef)
        .snapshots()
        .map((event) => event.docs.isNotEmpty);
  }

  static Stream<int> countAssistOnEvent({
    required String eventRef,
  }) {
    return FirebaseFirestore.instance
        .collection("posts")
        .doc(eventRef)
        .collection("assists")
        .snapshots()
        .map(
          (event) => event.docs.length,
        );
  }
}
