import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class SpotifyCtrl extends GetxController {
  void login() async {
    try {
      final token = await SpotifyService.loginWithSpotify();
    } catch (e) {
      print(e);
    }
  }
}
