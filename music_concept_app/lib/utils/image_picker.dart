import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

abstract class PickImageUtility {
  static Future<Uint8List?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    var base64 = await image?.readAsBytes();
    return base64;
  }

  static Future<Uint8List?> takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    var base64 = await image?.readAsBytes();
    return base64;
  }
}
