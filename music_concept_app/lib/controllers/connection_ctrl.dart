import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class ConnectionCtrl extends GetxController {
  final _pining = Rx<bool>(false);
  final _connectivityResult = Rx<bool?>(null);
  final _times = Rx<int>(0);
  final RxString _lastRoute = "/".obs;

  bool get pining => _pining.value;

  @override
  void onReady() {
    super.onReady();
    _checkConnection();
    _checkInternetAccess();
  }

  void _checkConnection() {
    _connectivityResult.listen((p0) {
      if (!p0!) {
        Get.delete<AuthenticationCtrl>();
        if (Get.currentRoute != "/not-wifi") {
          _lastRoute.value = Get.currentRoute;
          Get.offAndToNamed("/not-wifi");
        }
      } else {
        Get.put(AuthenticationCtrl(Get.find<FirebaseCtrl>().defaultApp));
        Get.find<HomeCtrl>().goToReed();
        if (Get.currentRoute == "/not-wifi") {
          Get.offAllNamed(_lastRoute.value);
        }
      }
    });
    _times.listen((p0) {
      if (p0 > 2) {
        SnackbarUtils.showSnackbar(
          message: "No hay conexión a internet",
          label: "Reintentar",
          onPressed: () => _request(),
        );
      }
      if (p0 > 5) {
        _connectivityResult.value = false;
      } else {
        _connectivityResult.value = true;
      }
    });
  }

  Future<void> _request() async {
    try {
      final result = await InternetAddress.lookup("google.com");
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _times.value = 0;
      }
    } on SocketException catch (_) {
      _times.value++;
    }
  }

  void ping() async {
    _pining.value = true;
    Future.delayed(const Duration(seconds: 5), () {
      _request().then((value) => _pining.value = false);
    });
  }

  void _checkInternetAccess() {
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _request();
    });
  }
}
