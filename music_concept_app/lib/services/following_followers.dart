import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

abstract class FollowingFollowersServices {
  static Future<void> followAccount({
    required String followerRef,
    required String followingRef,
  }) async {
    final isFollowing = await FirebaseFirestore.instance
        .collection("follows")
        .where("followingRef", isEqualTo: followingRef)
        .where("followerRef", isEqualTo: followerRef)
        .get();
    if (isFollowing.docs.isNotEmpty) return;

    await FirebaseFirestore.instance.collection("follows").add({
      "followingRef": followingRef,
      "followerRef": followerRef,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  static Future<void> unfollowAccount({
    required String followerRef,
    required String followingRef,
  }) async {
    var query = await FirebaseFirestore.instance
        .collection("follows")
        .where("followingRef", isEqualTo: followingRef)
        .where("followerRef", isEqualTo: followerRef)
        .get();
    query.docs.first.reference.delete();
  }

  static Stream<int> getFollowersCount(String? accountRef) {
    return FirebaseFirestore.instance
        .collection("follows")
        .where("followingRef", isEqualTo: accountRef)
        .snapshots()
        .map((event) => event.docs.length);
  }

  static Stream<int> getFollowingCount(String? accountRef) {
    return FirebaseFirestore.instance
        .collection("follows")
        .where("followerRef", isEqualTo: accountRef)
        .snapshots()
        .map((event) => event.docs.length);
  }

  static Stream<bool> isFollowing({
    required String followerRef,
    required String followingRef,
  }) {
    return FirebaseFirestore.instance
        .collection("follows")
        .where("followingRef", isEqualTo: followingRef)
        .where("followerRef", isEqualTo: followerRef)
        .snapshots()
        .map((event) => event.docs.isNotEmpty);
  }

  static Future<List<String>> getFollowersRefsFuture(String accountRef) {
    return FirebaseFirestore.instance
        .collection("follows")
        .where("followingRef", isEqualTo: accountRef)
        .get()
        .then((value) => value.docs
            .map(
              (e) => e["followerRef"] as String,
            )
            .toList());
  }

  static Stream<List<String>> getFollowers({required String accountRef}) {
    return FirebaseFirestore.instance
        .collection("follows")
        .where("followingRef", isEqualTo: accountRef)
        .snapshots()
        .map(
          (event) =>
              event.docs.map((e) => e.data()['followerRef'] as String).toList(),
        );
  }

  static Future<List<String>> getFollowingsFuture(
      {required String accountRef}) {
    return FirebaseFirestore.instance
        .collection("follows")
        .where("followerRef", isEqualTo: accountRef)
        .get()
        .then(((event) => event.docs
            .map((e) => e.data()['followingRef'] as String)
            .toList()));
  }

  static Stream<List<String>> getFollowings({required String accountRef}) {
    return FirebaseFirestore.instance
        .collection("follows")
        .where("followerRef", isEqualTo: accountRef)
        .snapshots()
        .map((event) =>
            event.docs.map((e) => e.data()['followingRef'] as String).toList());
  }

  static Stream<List<String>> getFriends({required String accountRef}) {
    return FirebaseFirestore.instance
        .collection("follows")
        .where("followingRef", isEqualTo: accountRef)
        .snapshots()
        .asyncMap((event) async {
      var friends = <FdSnapshot>[];
      for (var item in event.docs) {
        var isAFriend = await accountIsFriendFuture(
            accountRef: item.data()['followingRef'],
            userRef: item.data()['followerRef']);
        if (isAFriend) {
          friends.add(item);
        }
      }
      return friends.map((e) => e.data()!['followerRef'] as String).toList();
    });
  }

  // Future get friends

  static Future<List<String>> getFriendsFuture(
      {required String accountRef}) async {
    final query = await FirebaseFirestore.instance
        .collection("follows")
        .where("followingRef", isEqualTo: accountRef)
        .get();

    var friends = <FdSnapshot>[];
    for (var item in query.docs) {
      var isAFriend = await accountIsFriendFuture(
          accountRef: item.data()['followingRef'],
          userRef: item.data()['followerRef']);
      if (isAFriend) {
        friends.add(item);
      }
    }
    return friends.map((e) => e.data()!['followerRef'] as String).toList();
  }

  static Future<bool> accountIsFriendFuture({
    required String accountRef,
    required String userRef,
  }) {
    return FirebaseFirestore.instance
        .collection("follows")
        .where("followingRef", whereIn: [accountRef, userRef])
        .get()
        .then((value) {
          var isFollowing = value.docs.firstWhereOrNull((element) =>
              element.data()['followingRef'] == userRef &&
              element.data()['followerRef'] == accountRef);
          var isFollower = value.docs.firstWhereOrNull((element) =>
              element.data()['followingRef'] == accountRef &&
              element.data()['followerRef'] == userRef);
          return isFollower != null && isFollowing != null;
        });
  }

  static Stream<bool> accountIsFriend({
    required String accountRef,
    required String userRef,
  }) {
    return FirebaseFirestore.instance
        .collection("follows")
        .where("followingRef", whereIn: [accountRef, userRef])
        .snapshots()
        .map((value) {
          var isFollowing = value.docs.firstWhereOrNull((element) =>
              element.data()['followingRef'] == userRef &&
              element.data()['followerRef'] == accountRef);
          var isFollower = value.docs.firstWhereOrNull((element) =>
              element.data()['followingRef'] == accountRef &&
              element.data()['followerRef'] == userRef);
          return isFollower != null && isFollowing != null;
        });
  }
}
