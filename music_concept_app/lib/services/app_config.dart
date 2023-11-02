import 'package:cloud_firestore/cloud_firestore.dart';

abstract class AppConfigService {
  static DocumentReference<Map<String, dynamic>> get appConfigRef =>
      FirebaseFirestore.instance.collection('app_config').doc('config');

  static Stream<List<String>> get bussinessCategories => appConfigRef
      .snapshots()
      .map((event) => event.data()!['bussiness_categories'].cast<String>());
}
