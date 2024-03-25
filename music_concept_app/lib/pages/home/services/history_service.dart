import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:music_concept_app/lib.dart';

class HistoryService {
  static Future<History> createHistory(History history) async {
    final historyPath = "histories/${history.userCreatorId}";
    final imageUrl = await FirebaseStorageService.uploadFile(
      path: historyPath,
      fileName: history.createdAt.toIso8601String(),
      fileExtension: "jpg",
      fileData: base64Encode(history.imageBytes!),
      metadata: SettableMetadata(contentType: "image/jpg"),
    );

    return FirebaseFirestore.instance.collection("histories").add({
      ...history.toJson(),
      "imageUrl": imageUrl,
    }).then((value) {
      return history;
    });
  }

  static Future<List<History>> getHistoriesFromFollowingUsers(
      String userRef) async {
    final followingUsers = await FollowingFollowersServices.getFollowingsFuture(
        accountRef: userRef);
    final histories = <History>[];
    for (final followingUser in followingUsers) {
      final userHistories = await FirebaseFirestore.instance
          .collection("histories")
          .where("userCreatorId", isEqualTo: followingUser)
          .where("createdAt",
              isGreaterThan: DateTime.now().subtract(const Duration(days: 1)))
          .get();
      for (final history in userHistories.docs) {
        histories.add(History.fromJson(history.data()));
      }
    }
    return histories;
  }
}
