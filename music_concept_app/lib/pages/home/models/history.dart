import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';

class UserCreator extends Equatable {
  final String name;
  final String imageUrl;

  UserCreator({
    required this.name,
    required this.imageUrl,
  });

  factory UserCreator.fromJson(Map<String, dynamic> json) {
    return UserCreator(
      name: json["name"],
      imageUrl: json["image"],
    );
  }

  @override
  List<Object?> get props => [name, imageUrl];
}

class History extends Equatable {
  final String id;
  final String userCreatorId;
  final String description;
  final String? imageUrl;
  final Uint8List? imageBytes;
  UserCreator? userCreator;
  final DateTime createdAt;
  bool isMine;

  History({
    required this.id,
    required this.userCreatorId,
    required this.description,
    this.userCreator,
    this.imageUrl,
    this.imageBytes,
    required this.createdAt,
    this.isMine = false,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userCreatorId": userCreatorId,
      "description": description,
      "imageUrl": imageUrl,
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      id: json["id"],
      userCreatorId: json["userCreatorId"],
      description: json["description"],
      imageUrl: json["imageUrl"],
      createdAt: json["createdAt"].toDate(),
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [id, createdAt];
}
