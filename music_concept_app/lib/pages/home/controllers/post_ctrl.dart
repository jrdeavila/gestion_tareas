import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class CreatePostCtrl extends GetxController {
  final FirebaseApp _app;

  CreatePostCtrl(this._app);

  FirebaseAuth get _authApp => FirebaseAuth.instanceFor(app: _app);

  final RxString _content = ''.obs;
  final Rx<Uint8List?> _image = Rx<Uint8List?>(null);
  final Rx<PostVisibility> _visibility = PostVisibility.public.obs;

  final RxBool _isUploading = false.obs;

  String get content => _content.value;
  Uint8List? get image => _image.value;
  PostVisibility get visibility => _visibility.value;
  bool get isUploading => _isUploading.value;

  void setContent(String content) {
    _content.value = content;
  }

  void setImage(Uint8List? image) {
    _image.value = image;
  }

  void setVisibility(PostVisibility visibility) {
    _visibility.value = visibility;
  }

  void resetContent() {
    _content.value = "";
    _isUploading.value = false;
    _image.value = null;
  }

  void submit() async {
    final accountRef = "users/${_authApp.currentUser!.uid}";
    _isUploading.value = true;

    await PostService.createPost(
      accountRef: accountRef,
      content: _content.validateEmpty(),
      image: image,
      visibility: visibility,
    );
    _isUploading.value = false;
    Get.back();
  }
}

class PostCtrl extends GetxController {
  final FirebaseApp _app;

  PostCtrl(this._app);

  FirebaseAuth get _authApp => FirebaseAuth.instanceFor(app: _app);

  final RxList<FdSnapshot> _posts = <FdSnapshot>[].obs;
  final RxBool _isLoading = true.obs;

  List<FdSnapshot> get posts => _posts.toList();
  bool get isLoading => _isLoading.value;

  @override
  void onReady() {
    super.onReady();
    _posts.bindStream(_fetchingPost);
  }

  Stream<List<FdSnapshot>> get _fetchingPost =>
      PostService.getAccountFollowingPost("users/${_authApp.currentUser!.uid}")
          .asyncMap((event) async {
        _isLoading.value = true;
        await Future.delayed(1.seconds);
        _isLoading.value = false;
        return event;
      });

  Stream<DocumentSnapshot<Map<String, dynamic>>> getAccountRef(
      String accountRef) {
    return FirebaseFirestore.instance.doc(accountRef).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getOptions(String surveyId) {
    return SurveyService.getSurveyOptions(surveyId);
  }

  Stream<int> getOptionAnswerCount({
    required String surveyRef,
    required String optionRef,
  }) {
    return SurveyService.getOptionAnswerCount(
        optionRef: optionRef, surveyRef: surveyRef);
  }

  Stream<bool> accountHasAnswerOption({
    required String optionRef,
    required String surveyRef,
  }) {
    return SurveyService.hasOptionAnswer(
      surveyRef: surveyRef,
      optionRef: optionRef,
      accountRef: "users/${_authApp.currentUser?.uid}",
    );
  }

  Stream<bool> accountLikedPost({
    required String postRef,
  }) {
    return LikesCommentsService.isLiked(
      accountRef: "users/${_authApp.currentUser!.uid}",
      likeableRef: postRef,
    );
  }

  Stream<int> countLikesPost({
    required String postRef,
  }) {
    return LikesCommentsService.countLikes(
      likeableRef: postRef,
    );
  }

  Stream<int> getTopOption(String surveyRef) {
    return SurveyService.getTopOption(surveyRef);
  }

  Stream<int> countCommentsPost({
    required String postRef,
  }) {
    return LikesCommentsService.countComments(commentableRef: postRef);
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> profilePosts(
      {String? guestRef}) {
    return PostService.getAccountPosts(
        guestRef ?? "users/${_authApp.currentUser!.uid}");
  }

  void deletePost(String postRef) {
    PostService.deletePost(postRef);
  }

  void createSurveyAnwser({
    required String surveyRef,
    required String optionRef,
  }) {
    SurveyService.createOptionAnswer(
      surveyRef: surveyRef,
      optionRef: optionRef,
      accountRef: "users/${_authApp.currentUser?.uid}",
    );
  }

  void deleteSurveyAnwser({
    required String surveyRef,
    required String optionRef,
  }) {
    SurveyService.deleteOptionAnswer(
      surveyRef: surveyRef,
      optionRef: optionRef,
      accountRef: "users/${_authApp.currentUser?.uid}",
    );
  }

  void changeSurveyAnswer({
    required String surveyRef,
    required String optionRef,
  }) {
    SurveyService.changeOptionAnswer(
      surveyRef: surveyRef,
      optionRef: optionRef,
      accountRef: "users/${_authApp.currentUser?.uid}",
    );
  }

  void likePost({required String postRef}) {
    LikesCommentsService.likeLikeable(
      accountRef: _authApp.currentUser!.uid,
      likeableRef: postRef,
    );
  }

  void dislikePost({required String postRef}) {
    LikesCommentsService.dislikeLikeable(
      accountRef: _authApp.currentUser!.uid,
      likeableRef: postRef,
    );
  }
}

final postOptions = {
  PostVisibility.public: {
    "label": "Publico",
    "icon": MdiIcons.earth,
  },
  PostVisibility.followers: {
    "label": "Seguidores",
    "icon": MdiIcons.accountMultiple,
  },
  PostVisibility.private: {
    "label": "Privado",
    "icon": MdiIcons.lock,
  }
};

IconData getVisibilityIcon(int? index) {
  switch (index) {
    case 0:
      return MdiIcons.earth;
    case 1:
      return MdiIcons.accountMultiple;
    case 2:
      return MdiIcons.lock;
    default:
      return MdiIcons.earth;
  }
}
