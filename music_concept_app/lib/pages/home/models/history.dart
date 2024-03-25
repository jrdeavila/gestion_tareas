import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class History {
  final String userCreatorId;
  final String title;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final DateTime createdAt;

  History({
    required this.userCreatorId,
    required this.title,
    this.imageUrl,
    this.imageBytes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      "userCreatorId": userCreatorId,
      "title": title,
      "imageUrl": imageUrl,
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      userCreatorId: json["userCreatorId"],
      title: json["title"],
      imageUrl: json["imageUrl"],
      createdAt: json["createdAt"].toDate(),
    );
  }
}
