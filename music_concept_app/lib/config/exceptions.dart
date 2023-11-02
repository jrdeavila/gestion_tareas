import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:music_concept_app/lib.dart';

abstract class HandlerException {
  static void handler(Object e, StackTrace? stackTrace) {
    if (e is FirebaseException) {
      SnackbarUtils.onFirebaseException(e.code);
      return;
    }

    if (e is MessageException) {
      SnackbarUtils.onException(e.message);
      return;
    }
    if (e is DioException && e.type == DioExceptionType.cancel) {
      return;
    }
  }
}

class MessageException implements Exception {
  final String message;

  MessageException(this.message);

  @override
  String toString() {
    return message;
  }
}
