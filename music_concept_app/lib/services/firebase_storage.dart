import 'package:firebase_storage/firebase_storage.dart';
import 'package:music_concept_app/lib.dart';

class FirebaseStorageService {
  static const String storagePath = AppDefaults.firebaseStorageBucket;

  static final FirebaseStorage _firebaseStorage =
      FirebaseStorage.instanceFor(bucket: storagePath);

  static Future<String> uploadFile({
    required String path,
    required String fileName,
    required String fileExtension,
    required String fileData,
    PutStringFormat format = PutStringFormat.raw,
    required SettableMetadata metadata,
  }) async {
    final String filePath = "$path/$fileName.$fileExtension";
    final UploadTask uploadTask =
        _firebaseStorage.ref(filePath).putString(fileData, format: format);
    final TaskSnapshot taskSnapshot = await uploadTask;
    final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  static Future<void> deleteFile({
    required String path,
    required String fileName,
    required String fileExtension,
  }) async {
    final String filePath = "$path/$fileName.$fileExtension";
    await _firebaseStorage.ref(filePath).delete();
  }
}
