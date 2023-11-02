import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class CreateSurverCtrl extends GetxController {
  final FirebaseApp _app;

  CreateSurverCtrl(this._app);

  FirebaseAuth get _authApp => FirebaseAuth.instanceFor(app: _app);

  final RxList<Map> options = RxList<Map>([
    {"value": "", "image": null},
    {"value": "", "image": null},
  ]);

  final RxString _content = ''.obs;
  final RxBool _allowMultipleVotes = false.obs;
  final RxBool _allowAddOptions = false.obs;
  final Rx<PostVisibility> _visibility = PostVisibility.public.obs;
  final RxBool _isUploading = false.obs;

  bool get allowMultipleVotes => _allowMultipleVotes.value;
  bool get allowAddOptions => _allowAddOptions.value;
  PostVisibility get visibility => _visibility.value;
  bool get isUploading => _isUploading.value;

  void addItem() {
    final checkCurrent = options.any((element) => element["value"].isEmpty);
    final countLimit = options.length <= 10;
    if (!checkCurrent && countLimit) {
      options.add({"value": "", "image": null});
    }
  }

  void removeItem(int index) {
    if (options.length > 2) {
      options.removeAt(index);
    }
  }

  void onChangeByIndex(int index, String value) {
    options[index]["value"] = value;
  }

  void onChangeImageByIndex(int index, Uint8List? image) {
    options[index]["image"] = image;
  }

  void setContent(String content) {
    _content.value = content;
  }

  void setAllowMultipleVotes() {
    _allowMultipleVotes.value = !_allowMultipleVotes.value;
  }

  void setAllowAddOptions() {
    _allowAddOptions.value = !_allowAddOptions.value;
  }

  void setVisibility(PostVisibility value) {
    _visibility.value = value;
  }

  void submit() async {
    _isUploading.value = true;
    await SurveyService.createSurvey(
      accountRef: "users/${_authApp.currentUser?.uid}",
      content: _content.value,
      options: options,
      allowMultipleVotes: allowMultipleVotes,
      allowAddOptions: allowAddOptions,
      visibility: visibility,
    );
    _isUploading.value = false;
    Get.back();
  }
}

class FollowerEditSurveyItemsCtrl extends GetxController {
  final FirebaseApp _app;

  FollowerEditSurveyItemsCtrl(this._app);

  FirebaseAuth get _authApp => FirebaseAuth.instanceFor(app: _app);

  final RxString _content = ''.obs;
  final Rx<Uint8List?> _image = Rx<Uint8List?>(null);
  final RxInt currentOptions = RxInt(0);
  final Rx<String?> _surveyRef = Rx<String?>(null);
  final RxBool _isNew = false.obs;

  String get content => _content.value;
  Uint8List? get image => _image.value;
  bool get isNew => _isNew.value;
  bool get hasContent => content.isNotEmpty;

  @override
  void onReady() {
    super.onReady();
    _surveyRef.listen((p0) {
      if (p0 != null) {
        SurveyService.getSurveyOptions(p0).listen((p1) {
          currentOptions.value = p1.docs.length;
        });
      }
    });
  }

  void setCurrentOptions(String surveyRef) {
    _surveyRef.value = surveyRef;
  }

  void addItem() {
    _isNew.value = currentOptions.value + 1 <= 100;
  }

  void removeItem() {
    _isNew.value = false;
  }

  void onChange(String value) {
    _content.value = value;
  }

  void onChangeImage(Uint8List? image) {
    _image.value = image;
  }

  void submit() {
    SurveyService.addOnlyOneOption(
      surveyRef: "posts/${_surveyRef.value}",
      value: _content.value,
      image: _image.value,
      accountRef: "users/${_authApp.currentUser?.uid}",
    ).then((value) {
      _isNew.value = false;
      _content.value = "";
      _image.value = null;
    });
  }
}
