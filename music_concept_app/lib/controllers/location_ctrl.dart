import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationCtrl extends GetxController {
  final RxBool _hasPermissions = false.obs;
  final RxBool _incognitoMode = false.obs;
  final Rx<LocationPermission?> _permissions = Rx(null);
  final Rx<Position?> _position = Rx(null);
  Position? get position => _position.value;
  bool get hasPermissions => _hasPermissions.value && !incognitoMode;
  bool get incognitoMode => _incognitoMode.value;
  bool get permissionsBlocked =>
      _permissions.value == LocationPermission.deniedForever;

  LatLng get latLng => LatLng(
        _position.value?.latitude ?? -73.2538,
        _position.value?.longitude ?? 10.002,
      );

  void setHasPermissions(bool hasPermissions) {
    _hasPermissions.value = hasPermissions;
  }

  @override
  void onReady() {
    super.onReady();
    Geolocator.getLastKnownPosition().then((value) {
      return _position.value = value;
    });
    _position.bindStream(Geolocator.getPositionStream());
    _incognitoMode.value = GetStorage().read('incognitoMode') ?? false;
    _incognitoMode.listen((p0) {
      GetStorage().write('incognitoMode', p0);
    });

    _hasPermissions.listen((p0) {
      if (p0 == false) {}
    });
    _permissions.listen((p0) {
      if (p0 == LocationPermission.denied ||
          p0 == LocationPermission.deniedForever) {
        _hasPermissions.value = false;
      } else {
        _hasPermissions.value = true;
      }
    });

    requestPermissions();
  }

  void requestPermissions() async {
    var hasPerms = await Geolocator.checkPermission();
    if (hasPerms != LocationPermission.denied &&
        hasPerms != LocationPermission.deniedForever) {
      _permissions.value = hasPerms;
    } else {
      final permissions = await Geolocator.requestPermission();
      _permissions.value = permissions;
    }
  }

  void goToSettings() async {
    await Geolocator.openAppSettings();
  }

  void toggleIngcognitoMode() async {
    _incognitoMode.value = !_incognitoMode.value;
  }
}

extension PositionLatLng on Position {
  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }
}
