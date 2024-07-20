import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class LoginCtrl extends GetxController {
  final RxString _email = RxString("");
  final RxString _password = RxString("");

  void setEmail(String value) => _email.value = value.trim();
  void setPassword(String value) => _password.value = value.trim();

  void submit() {
    Get.find<AuthenticationCtrl>().login(
      email: _email.validateEmail(),
      password: _password.validateEmpty(),
    );
  }
}

class RegisterCtrl extends GetxController {
  final RxString _email = RxString("");
  final RxString _password = RxString("");
  final RxString _name = RxString("");
  final Rx<Uint8List?> _image = Rx<Uint8List?>(null);
  final RxDouble _page = RxDouble(0);

  double get page => _page.value;
  String get email => _email.value;
  String get password => _password.value;
  String get name => _name.value;

  void setEmail(String value) => _email.value = value;
  void setPassword(String value) => _password.value = value;
  void setName(String value) => _name.value = value;
  void setImage(Uint8List? value) => _image.value = value;

  void nextPage() {
    _email.validateEmail();
    _password.validateEmpty(label: "Contraseña");
    _page.value = 1;
  }

  void previousPage() {
    _page.value = 0;
  }

  void goToBussiness() {
    Get.toNamed(AppRoutes.businessRegister, arguments: {
      "name": _name.validateEmpty(
        label: "Nombre",
      ),
      "email": _email.validateEmail(),
      "password": _password.validateEmpty(
        label: "Contraseña",
      ),
      "image": _image.value,
    });
  }

  void submit() {
    Get.find<AuthenticationCtrl>().register(
      name: _name.validateEmpty(
        label: "Nombre",
      ),
      email: _email.validateEmail(),
      password: _password.validateEmpty(
        label: "Contraseña",
      ),
      image: _image.value,
    );
  }
}

class ResetPasswordCtrl extends GetxController {
  final RxString _email = RxString("");

  void setEmail(String value) => _email.value = value;

  void submit() {
    Get.find<AuthenticationCtrl>().resetPassword(
      email: _email.validateEmail(),
    );
    Get.back();
  }
}
