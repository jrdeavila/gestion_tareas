import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:music_concept_app/lib.dart';

class Coordinates {
  final double latitude;
  final double longitude;
  const Coordinates({
    required this.latitude,
    required this.longitude,
  });

  factory Coordinates.fromMap(Map<String, dynamic> map) {
    return Coordinates(
      latitude: map["latitude"],
      longitude: map["longitude"],
    );
  }
}

abstract class BusinessService {
  static Future<List<FdSnapshot>> searchBusinessNearly(
      {required Coordinates coordinates, required double radius}) async {
    final query = await FirebaseFirestore.instance
        .collection("users")
        .where(
          "type",
          isEqualTo: UserAccountType.business.index,
        )
        .get();

    return query.docs.where((element) {
      var point = element.data()['location'] as GeoPoint?;
      if (point == null) {
        return false;
      }
      return Geolocator.distanceBetween(
            point.latitude,
            point.longitude,
            coordinates.latitude,
            coordinates.longitude,
          ) <
          radius;
    }).toList();
  }

  static Future<void> createBusinessVisit({
    required String accountRef,
    required String businessRef,
  }) async {
    var query = await FirebaseFirestore.instance
        .collection("business_visits")
        .where("accountRef", isEqualTo: accountRef)
        .where("businessRef", isEqualTo: businessRef)
        .get();
    var haveToDay = query.docs.any((element) {
      var createdAt = (element["createdAt"] as Timestamp).toDate();
      var diff = createdAt.difference(DateTime.now()).inDays;
      return diff == 0;
    });
    if (!haveToDay) {
      await FirebaseFirestore.instance.collection("business_visits").add({
        "accountRef": accountRef,
        "businessRef": businessRef,
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
  }

  static Future<void> setCurrentVisit(
      {required String accountRef, String? businessRef}) async {
    await FirebaseFirestore.instance.doc(accountRef).update({
      "currentVisit": businessRef,
    });
  }

  static Stream<FdSnapshot> getCurrentVisit({
    required String accountRef,
  }) async* {
    var ref = await FirebaseFirestore.instance.doc(accountRef).get();
    var businessRef = ref.data()!['currentVisit'];
    yield* FirebaseFirestore.instance.doc(businessRef).snapshots();
  }

  // Saber si las personas que sigues estan en el mismo sitio que tu
  static Stream<List<String>> getFollingInCurrentVisit({
    required String accountRef,
  }) async* {
    var ref = await FirebaseFirestore.instance.doc(accountRef).get();
    var businessRef = ref.data()!['currentVisit'];
    yield* FirebaseFirestore.instance
        .collection("follows")
        .where("followerRef", isEqualTo: accountRef)
        .snapshots()
        .asyncMap((event) async {
      var refs = event.docs.map((e) => e.data()['followingRef'] as String);
      List<String> followingRefs = [];
      for (String userRef in refs) {
        var user = await FirebaseFirestore.instance.doc(userRef).get();
        if (user.data()!['currentVisit'] == businessRef) {
          followingRefs.add(userRef);
        }
      }
      return followingRefs;
    });
  }

  static Stream<List<FdSnapshot>> getBusinessVisits({
    required String accountRef,
  }) {
    return FirebaseFirestore.instance
        .collection("business_visits")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .where((element) => element.data()['accountRef'] == accountRef)
              .toList(),
        );
  }

  static Stream<List<FdSnapshot>> getVisitors({
    required String businessRef,
  }) {
    return FirebaseFirestore.instance
        .collection("business_visits")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .where((element) => element.data()['businessRef'] == businessRef)
              .toList(),
        );
  }
}
