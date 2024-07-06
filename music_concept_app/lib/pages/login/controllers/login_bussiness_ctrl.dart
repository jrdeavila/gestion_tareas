import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:music_concept_app/lib.dart';

class RegisterBussinessCtrl extends GetxController {
  final RxString _email = RxString("");
  final RxString _password = RxString("");
  final RxString _name = RxString("");
  final RxString _address = RxString("");
  final RxString _category = RxString("");
  final Rx<LatLng?> _location = Rx<LatLng?>(null);
  final Rx<Uint8List?> _image = Rx<Uint8List?>(null);

  final RxList<String> categories = RxList<String>([]);

  LatLng? get location => _location.value;
  String get address => _address.value;

  @override
  void onReady() {
    super.onReady();
    _location.value = Get.find<LocationCtrl>().position?.toLatLng();
    categories.bindStream(AppConfigService.bussinessCategories);
  }

  void loadInfo(Map<String, dynamic>? data) {
    if (data == null) return;
    _name.value = data["name"];
    _email.value = data["email"];
    _password.value = data["password"];
    _image.value = data["image"];
  }

  void setAddress(String value) => _address.value = value;
  void setCategory(String value) => _category.value = value;
  void setLocation(LatLng? value) => _location.value = value;

  void submit() {
    try {
      Get.find<AuthenticationCtrl>().register(
        email: _email.validateEmail(),
        password: _password.validateEmpty(
          label: "Contraseña",
        ),
        name: _name.validateEmpty(
          label: "Nombre",
        ),
        address: _address.validateEmpty(
            label: "Dirección",
            message: "Por favor, ingrese una dirección valida"),
        category: _category.validateEmpty(
          label: "Categoría",
          message: "Por favor, seleccione una categoría",
        ),
        location: _location.validateNull(
          label: "Ubicación",
          message: "Por favor, seleccione una ubicación",
        ),
        image: _image.value,
        type: UserAccountType.business,
      );
    } on MessageException catch (e) {
      Get.snackbar("Error", e.message, backgroundColor: Colors.red);
    }
  }
}
