import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:music_concept_app/lib.dart';

abstract class ChatService {
  static Future<String> createConversation({
    required String senderRef,
    required String receiverRef,
  }) async {
    if (kDebugMode) {
      print("Create a conversation between $senderRef and $receiverRef");
    }
    var find = await FirebaseFirestore.instance
        .collection("conversations")
        .where("participants", whereIn: [
      [senderRef, receiverRef],
      [receiverRef, senderRef],
    ]).get();
    if (find.docs.isNotEmpty) {
      return find.docs.first.reference.path;
    }
    var doc = await FirebaseFirestore.instance.collection("conversations").add({
      "participants": [senderRef, receiverRef],
      "lastMessage": null,
      "firstAttempt": true,
      "creatorRef": senderRef,
      "timestamp": FieldValue.serverTimestamp(),
    });
    return doc.path;
  }

  static Future<void> updateFirstAttempt(
      {required String conversationRef, required bool value}) async {
    if (kDebugMode) {
      print("Update first attempt in $conversationRef to $value");
    }
    return FirebaseFirestore.instance.doc(conversationRef).update({
      "firstAttempt": value,
    });
  }

  static Future<void> deleteConversation(
      {required String conversationRef}) async {
    if (kDebugMode) {
      print("Delete conversation $conversationRef");
    }
    return FirebaseFirestore.instance.doc(conversationRef).delete();
  }

  static Stream<FdSnapshot> getConversation(String conversationRef) {
    if (kDebugMode) {
      print("Get conversation $conversationRef");
    }
    return FirebaseFirestore.instance.doc(conversationRef).snapshots();
  }

  static Future<void> receiverSeenMessage({
    required String conversationRef,
  }) async {
    if (kDebugMode) {
      print("Receiver seen message in $conversationRef");
    }
    await FirebaseFirestore.instance.doc(conversationRef).update({
      "receiverSeen": true,
    });
  }

  static Future<void> viewConversation({
    required String conversationRef,
  }) async {
    if (kDebugMode) {
      print("View conversation $conversationRef");
    }
    await FirebaseFirestore.instance.doc(conversationRef).update({
      "receiverSeen": true,
      "receiverSeenTimestamp": FieldValue.serverTimestamp(),
    });
  }

  static Future<void> sendMessage({
    required String senderRef,
    required String conversationRef,
    required String message,
  }) async {
    if (kDebugMode) {
      print("Send message $message from $senderRef to $conversationRef");
    }
    await FirebaseFirestore.instance
        .doc(conversationRef)
        .collection("messages")
        .add({
      "senderRef": senderRef,
      "message": message,
      "timestamp": FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.doc(conversationRef).update({
      "lastMessage": message,
      "receiverSeen": false,
      "lastSenderRef": senderRef,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  static Stream<List<FdSnapshot>> getChats({
    required String conversationRef,
  }) {
    return FirebaseFirestore.instance
        .doc(conversationRef)
        .collection("messages")
        .orderBy("timestamp")
        .snapshots()
        .map((event) => event.docs);
  }

  static Stream<List<FdSnapshot>> getChatList(String? accountRef) {
    return FirebaseFirestore.instance
        .collection("conversations")
        .where("participants", arrayContains: accountRef)
        .snapshots()
        .map((event) {
      var grouped = <List, FdSnapshot>{};
      for (var item in event.docs) {
        var key = (item.data()['participants'] as List).cast<String>()..sort();
        var crt = grouped[key];
        var itemDate = (item.data()['timestamp'] as Timestamp?)?.toDate();
        if (crt != null && itemDate != null) {
          var crtDate = (crt.data()!['timestamp'] as Timestamp?)?.toDate();

          if (crtDate != null && itemDate.isAfter(crtDate)) {
            grouped[key] = item;
          }
        } else {
          grouped[key] = item;
        }
      }
      grouped.removeWhere((key, value) => value.data()?['lastMessage'] == null);
      var values = grouped.values.toList();
      values.sort((a, b) {
        var aDate = (a.data()!['timestamp'] as Timestamp?)?.toDate();
        var bDate = (b.data()!['timestamp'] as Timestamp?)?.toDate();
        if (aDate != null && bDate != null) {
          return bDate.compareTo(aDate);
        }
        return 0;
      });
      return values;
    });
  }
}
