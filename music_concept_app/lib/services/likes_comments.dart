import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_concept_app/lib.dart';

abstract class LikesCommentsService {
  static Stream<QuerySnapshot<Map<String, dynamic>>> getComments({
    required String postRef,
  }) async* {
    var post = await FirebaseFirestore.instance.doc(postRef).get();
    if (post.exists) {
      yield* FirebaseFirestore.instance
          .doc(postRef)
          .collection("comments")
          .orderBy("createdAt", descending: true)
          .snapshots();
    }
  }

  static Future<void> commentCommentable({
    required String accountRef,
    required String commentableRef,
    required String content,
  }) async {
    await FirebaseFirestore.instance
        .doc(commentableRef)
        .collection("comments")
        .add({
      "accountRef": "users/$accountRef",
      "content": content,
      "createdAt": FieldValue.serverTimestamp(),
    });
    var userRef = await _getOwnerableRef(commentableRef);
    if (userRef != null && userRef != "users/$accountRef") {
      NotificationService.sendNotification(
          accountRef: userRef,
          title: "Nuevo comentario",
          body: "Alguien ha comentado tu publicación",
          type: NotificationType.comment,
          arguments: {
            "ref": commentableRef,
          });
    }
  }

  static Future<String?> _getOwnerableRef(String ownerable) async {
    try {
      var snapshot = await FirebaseFirestore.instance.doc(ownerable).get();
      if (snapshot.exists) {
        return snapshot.data()!["accountRef"];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> deleteComment({
    required String postRef,
    required String commentRef,
  }) {
    return FirebaseFirestore.instance
        .doc(postRef)
        .collection("comments")
        .doc(commentRef)
        .delete();
  }

  static Stream<int> countComments({
    required String commentableRef,
  }) {
    return FirebaseFirestore.instance
        .doc(commentableRef)
        .collection("comments")
        .snapshots()
        .map(
          (event) => event.docs.length,
        );
  }

  static Future<void> likeLikeable({
    required String accountRef,
    required String likeableRef,
  }) {
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      await FirebaseFirestore.instance
          .doc(likeableRef)
          .collection("likes")
          .doc(accountRef)
          .set({
        "accountRef": "users/$accountRef",
        "createdAt": FieldValue.serverTimestamp(),
      });

      var userRef = await _getOwnerableRef(likeableRef);
      if (userRef != null && userRef != "users/$accountRef") {
        NotificationService.sendNotification(
            accountRef: userRef,
            title: "Nuevo like",
            body: "Alguien ha dado like a tu publicación",
            type: NotificationType.like,
            arguments: {
              "ref": likeableRef,
            });
      }
    });
  }

  static Future<void> dislikeLikeable({
    required String accountRef,
    required String likeableRef,
  }) {
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      FirebaseFirestore.instance
          .doc(likeableRef)
          .collection("likes")
          .doc(accountRef)
          .delete();
    });
  }

  static Stream<int> countLikes({
    required String likeableRef,
  }) {
    return FirebaseFirestore.instance
        .doc(likeableRef)
        .collection("likes")
        .snapshots()
        .map(
          (event) => event.docs.length,
        );
  }

  static Stream<bool> isLiked({
    required String accountRef,
    required String likeableRef,
  }) {
    return FirebaseFirestore.instance
        .doc(likeableRef)
        .collection("likes")
        .where("accountRef", isEqualTo: accountRef)
        .snapshots()
        .map((event) => event.docs.isNotEmpty);
  }
}
