import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:music_concept_app/lib.dart';

class HistoryService {
  static Future<History> createHistory(History history) async {
    final historyPath = "histories/${history.userCreatorId}";
    final imageUrl = await FirebaseStorageService.uploadFile(
      path: historyPath,
      fileName: history.id,
      fileExtension: "jpg",
      fileData: base64.encode(history.imageBytes!),
      format: PutStringFormat.base64,
      metadata: SettableMetadata(contentType: "image/jpeg"),
    );

    return FirebaseFirestore.instance.collection("histories").add({
      ...history.toJson(),
      "imageUrl": imageUrl,
    }).then((value) {
      return history;
    });
  }

  static Future<List<History>> getMyHistory(String userRef) async {
    final histories = await FirebaseFirestore.instance
        .collection("histories")
        .where("userCreatorId", isEqualTo: userRef)
        .get();
    final availableHistories = histories.docs.map((e) {
      return History.fromJson(e.data());
    }).toList();
    final historyIn24Hours = availableHistories
        .where((element) => element.createdAt
            .isAfter(DateTime.now().subtract(const Duration(days: 1))))
        .toList();

    final myHistories = <History>[];
    for (final history in historyIn24Hours) {
      final userCreatorDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(history.userCreatorId)
          .get();
      final userCreator = userCreatorDoc.data() != null
          ? UserCreator.fromJson(userCreatorDoc.data()!)
          : null;
      history.userCreator = userCreator;
      history.isMine = true;
      myHistories.add(history);
    }

    return myHistories;
  }

  static Future<Map<UserCreator, List<History>>> getHistoriesFromFollowingUsers(
      String userRef) async {
    final followingUsers = await FollowingFollowersServices.getFollowingsFuture(
        accountRef: "users/$userRef");
    final histories = <UserCreator, List<History>>{};
    for (final followingUser in followingUsers) {
      final ref = followingUser.replaceFirst("users/", "");
      final userHistories = await FirebaseFirestore.instance
          .collection("histories")
          .where("userCreatorId", isEqualTo: ref)
          .get();
      for (final history in userHistories.docs) {
        final userCreatorDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(history.data()["userCreatorId"])
            .get();
        final userCreator = userCreatorDoc.data() != null
            ? UserCreator.fromJson(userCreatorDoc.data()!)
            : null;
        final historyModel = History.fromJson(history.data());
        historyModel.userCreator = userCreator;
        if (historyModel.createdAt
            .isAfter(DateTime.now().subtract(const Duration(days: 1)))) {
          if (userCreator != null) {
            if (histories[userCreator] != null) {
              histories[userCreator]!.add(historyModel);
            } else {
              histories[userCreator] = [historyModel];
            }
          }
        }
      }
    }
    return histories;
  }

  static Future<bool> deleteHistory(History history) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection("histories")
          .where("id", isEqualTo: history.id)
          .get();

      await query.docs.first.reference.delete();

      await FirebaseStorageService.deleteFile(
        path: "histories/${history.userCreatorId}",
        fileName: history.id,
        fileExtension: "jpg",
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
