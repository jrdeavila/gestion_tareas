import 'dart:typed_data';

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
    categories.bindStream(AppConfigService.bussinessCategories);
  }

  void loadInfo(Map<String, dynamic> data) {
    _name.value = data["name"];
    _email.value = data["email"];
    _password.value = data["password"];
    _image.value = data["image"];
  }

  void setAddress(String value) => _address.value = value;
  void setCategory(String value) => _category.value = value;
  void setLocation(LatLng? value) => _location.value = value;

  void submit() {
    Get.find<AuthenticationCtrl>().register(
      email: _email.validateEmail(),
      password: _password.validateEmpty(
        label: "Contraseña",
      ),
      name: _name.validateEmpty(
        label: "Nombre",
      ),
      address: _address.validateEmpty(
        label: "Direccion",
      ),
      category: _category.validateEmpty(
        label: "Categoria",
      ),
      location: _location.validateNull(
        label: "Ubicacion",
      ),
      image: _image.value,
      type: UserAccountType.business,
    );
  }
}
