import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class SnackbarUtils {
  static void showSnackbar({
    required String message,
    required String label,
    void Function()? onPressed,
  }) {
    Get.showSnackbar(
      GetSnackBar(
        message: message,
        duration: const Duration(seconds: 3),
        mainButton: TextButton(
          onPressed: onPressed,
          child: Text(label),
        ),
      ),
    );
  }

  static void showBanner({
    required String title,
    required String message,
    required String label,
    IconData? icon,
    void Function()? onPressed,
  }) {
    Get.isSnackbarOpen
        ? Get.closeCurrentSnackbar()
        : Get.showSnackbar(
            GetSnackBar(
              padding: const EdgeInsets.all(10.0),
              icon: icon != null
                  ? Icon(
                      icon,
                      color: Get.theme.colorScheme.primary,
                      size: 30.0,
                    )
                  : null,
              title: title,
              message: message,
              margin: const EdgeInsets.all(10.0),
              borderRadius: 15.0,
              duration: 10.seconds,
              overlayBlur: 0.0,
              mainButton: TextButton(
                onPressed: onPressed,
                child: Text(label),
              ),
              snackPosition: SnackPosition.TOP,
            ),
          );
  }

  static void onException(String message) {
    showSnackbar(
      message: message,
      label: "OK",
    );
  }

  static void onFirebaseException(String code) {
    if (blockedList.contains(code)) return;
    showSnackbar(
      message: firebaseMessages[code] ?? code,
      label: "OK",
    );
  }
}

const firebaseMessages = {
  "invalid-email": "Email inválido",
  "user-disabled": "Usuário desabilitado",
  "user-not-found": "Usuário no encontrado",
  "wrong-password": "Contraseña incorrecta",
  "email-already-in-use": "Email ya en uso",
  "operation-not-allowed": "Operación no permitida",
  "weak-password": "Contraseña débil",
  "unknown": "Error desconocido",
  "failed-precondition": "Precondición fallida",
  "not-found": "No encontrado",
};

const blockedList = [
  "not-found",
  "failed-precondition",
];
