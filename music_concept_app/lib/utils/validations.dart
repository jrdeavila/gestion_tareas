import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

extension RxStringValidations on RxString {
  String validateEmail(
      {String label = "Email", String message = "Este correo no es valido"}) {
    return validateException(value.isEmail, "$label: $message");
  }

  String validateEmpty({
    String label = "Campo",
    String message = "Este campo no puede estar vacio",
  }) {
    return validateException(isNotEmpty, "$label: $message").trim();
  }
}

extension RxNullValidations on Rx {
  T validateNull<T>(
      {String label = "Campo",
      String message = "Este campo no debe ser nulo"}) {
    return validateException(value != null, "$label: $message");
  }

  dynamic validateException(bool validate, String message) {
    try {
      if (!validate) {
        throw MessageException(message);
      }
      return value;
    } catch (e) {
      throw MessageException(message);
    }
  }
}

extension RxDateValidations on Rx {
  T validateDateAfter<T>(
      {String label = "Campo",
      String message = "La fecha no puede ser menor a la actual",
      DateTime? date}) {
    return validateException(
        (value as DateTime).isAfter(date ?? DateTime.now()),
        "$label: $message");
  }

  T validateDateBefore<T>(
      {String label = "Campo",
      String message = "La fecha no puede ser mayor a la actual",
      DateTime? date}) {
    return validateException(
        (value as DateTime).isBefore(date ?? DateTime.now()),
        "$label: $message");
  }
}
