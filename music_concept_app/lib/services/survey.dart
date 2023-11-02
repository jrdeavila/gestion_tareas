import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:music_concept_app/lib.dart';

abstract class SurveyService {
  static Future<void> createSurvey({
    required String? accountRef,
    required String content,
    required List<Map> options,
    required bool allowMultipleVotes,
    required bool allowAddOptions,
    required PostVisibility visibility,
  }) {
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      var optUpl = [...options];
      final surveyRef =
          await FirebaseFirestore.instance.collection('posts').add({
        'accountRef': accountRef,
        'visibility': visibility.index,
        'content': content,
        'allowMultipleVotes': allowMultipleVotes,
        'allowAddOptions': allowAddOptions,
        'createdAt': FieldValue.serverTimestamp(),
        'deletedAt': null,
        "type": PostType.survey.index,
      });
      for (var i = 0; i < optUpl.length; i++) {
        final option = optUpl[i];
        _saveOneOption(
          option: option,
          accountRef: accountRef,
          surveyRef: surveyRef.path,
        );
      }
    });
  }

  static Future<void> _saveOneOption({
    required Map<dynamic, dynamic> option,
    required String? accountRef,
    required String surveyRef,
  }) async {
    final imagePath = option["image"] != null
        ? await FirebaseStorageService.uploadFile(
            path: "posts/$accountRef/",
            fileName: DateTime.now().millisecondsSinceEpoch.toString(),
            fileExtension: "jpg",
            fileData: base64.encode(option["image"]),
            format: PutStringFormat.base64,
            metadata: SettableMetadata(
              contentType: "image/jpeg",
            ),
          )
        : null;

    FirebaseFirestore.instance
        .doc(surveyRef)
        .collection("options")
        .doc(option["value"])
        .set({
      "option": option["value"],
      "image": imagePath,
      "createdBy": accountRef,
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getSurveyOptions(
      String surveyId) {
    return FirebaseFirestore.instance
        .collection("posts")
        .doc(surveyId)
        .collection("options")
        .snapshots();
  }

  static Future<void> createOptionAnswer({
    String? accountRef,
    required String surveyRef,
    required String optionRef,
  }) {
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final query = await FirebaseFirestore.instance
          .collection("posts")
          .doc(surveyRef)
          .collection("answers")
          .where("accountRef", isEqualTo: accountRef)
          .where("optionRef", isEqualTo: optionRef)
          .where("deletedAt", isNull: true)
          .get();

      if (query.docs.isEmpty) {
        FirebaseFirestore.instance
            .collection("posts")
            .doc(surveyRef)
            .collection("answers")
            .add({
          "accountRef": accountRef,
          "optionRef": optionRef,
          'createdAt': FieldValue.serverTimestamp(),
          "deletedAt": null,
        });
      }
    });
  }

  static Future<void> deleteOptionAnswer({
    String? accountRef,
    required String surveyRef,
    required String optionRef,
  }) {
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final query = await FirebaseFirestore.instance
          .collection("posts")
          .doc(surveyRef)
          .collection("answers")
          .where("accountRef", isEqualTo: accountRef)
          .where("optionRef", isEqualTo: optionRef)
          .get();

      for (var doc in query.docs) {
        await doc.reference.update({
          "deletedAt": FieldValue.serverTimestamp(),
        });
      }
    });
  }

  static Stream<bool> hasOptionAnswer({
    String? accountRef,
    required String surveyRef,
    required String optionRef,
  }) {
    return FirebaseFirestore.instance
        .collection("posts")
        .doc(surveyRef)
        .collection("answers")
        .where("deletedAt", isNull: true)
        .where("optionRef", isEqualTo: optionRef)
        .where("accountRef", isEqualTo: accountRef)
        .snapshots()
        .map((event) => event.docs.isNotEmpty);
  }

  static Stream<int> getOptionAnswerCount({
    required String surveyRef,
    required String optionRef,
  }) {
    return FirebaseFirestore.instance
        .collection("posts")
        .doc(surveyRef)
        .collection("answers")
        .where("optionRef", isEqualTo: optionRef)
        .where("deletedAt", isNull: true)
        .snapshots()
        .map((event) => event.docs.length);
  }

  static Stream<int> getTopOption(String surveyRef) {
    return FirebaseFirestore.instance
        .collection("posts")
        .doc(surveyRef)
        .collection("answers")
        .where("deletedAt", isNull: true)
        .snapshots()
        .map((event) {
      Map<String, int> counts = {};
      for (var doc in event.docs) {
        var ref = doc.data()["optionRef"];
        counts[ref] = (counts[ref] ?? 0) + 1;
      }
      int max = counts.values.reduce((a, b) {
        return a > b ? a : b;
      });
      return max;
    });
  }

  static Future<void> addOnlyOneOption({
    required String surveyRef,
    required String value,
    required Uint8List? image,
    required String accountRef,
  }) {
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      _saveOneOption(
        option: {
          "value": value,
          "image": image,
        },
        accountRef: accountRef,
        surveyRef: surveyRef,
      );
    });
  }

  static Future<void> deleteOnlyOneOption({
    required String surveyRef,
    required String value,
  }) {
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      return FirebaseFirestore.instance
          .doc(surveyRef)
          .collection("options")
          .doc(value)
          .update({
        "deletedAt": FieldValue.serverTimestamp(),
      });
    });
  }

  static Future<void> changeOptionAnswer({
    required String surveyRef,
    required String optionRef,
    required String accountRef,
  }) {
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final query = await FirebaseFirestore.instance
          .collection("posts")
          .doc(surveyRef)
          .collection("answers")
          .where("accountRef", isEqualTo: accountRef)
          .where("deletedAt", isNull: true)
          .get();

      if (query.docs.isEmpty) {
        await createOptionAnswer(
          surveyRef: surveyRef,
          optionRef: optionRef,
          accountRef: accountRef,
        );
        return;
      }
      for (var doc in query.docs) {
        await doc.reference.update({
          "optionRef": optionRef,
        });
      }
      return;
    });
  }
}
