import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:music_concept_app/lib.dart';

class FirebaseCtrl extends GetxController {
  final List<FirebaseApp> _apps;
  final GetStorage _getStorage = GetStorage();

  FirebaseCtrl(this._apps);
  Rx<String?> get _defaultApp =>
      Rx<String?>(_getStorage.read<String>("firebase-app"));

  String? get app => _defaultApp.value;

  List<FirebaseApp> get apps => _apps;

  @override
  void onReady() {
    super.onReady();
    Get.put(AuthenticationCtrl());
    Get.put(ConnectionCtrl());
    Get.put(LocationCtrl());
    Get.put(ActivityCtrl());
  }

  void changeDefault(String value) {
    _getStorage.write("firebase-app", value);
  }
}
