import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class CommentCtrl extends GetxController {
  final RxString _content = ''.obs;
  final RxBool _isUploading = false.obs;
  final RxList<DocumentSnapshot<Map<String, dynamic>>> comments = RxList();

  final Rx<String?> _selectedPostRef = Rx<String?>(null);

  String get content => _content.value;

  bool get isUploading => _isUploading.value;

  Stream<DocumentSnapshot<Map<String, dynamic>>> getAccount(String accountRef) {
    return UserAccountService.getUserAccountDoc(accountRef).snapshots();
  }

  Stream<FdSnapshot?> getPost(String postRef) {
    return PostService.getPost(postRef);
  }

  void setContent(String content) {
    _content.value = content;
  }

  void setSelectedPost(String? postRef) {
    _selectedPostRef.value = postRef;
    _selectedPostRef.refresh();
  }

  Stream<int> getCommentLikes({
    required String commentRef,
  }) {
    return LikesCommentsService.countLikes(
      likeableRef: commentRef,
    );
  }

  Stream<bool> isLikedComment({
    required String commentRef,
  }) {
    return LikesCommentsService.isLiked(
      accountRef: "users/${FirebaseAuth.instance.currentUser!.uid}",
      likeableRef: commentRef,
    );
  }

  void likeComment({
    required String commentRef,
  }) {
    LikesCommentsService.likeLikeable(
      accountRef: FirebaseAuth.instance.currentUser!.uid,
      likeableRef: commentRef,
    );
  }

  void dislikeComment({
    required String commentRef,
  }) {
    LikesCommentsService.dislikeLikeable(
      accountRef: FirebaseAuth.instance.currentUser!.uid,
      likeableRef: commentRef,
    );
  }

  @override
  void onInit() {
    super.onInit();
    _selectedPostRef.listen((value) {
      _loadComments(value);
    });
  }

  _loadComments(String? value) {
    if (value != null) {
      LikesCommentsService.getComments(postRef: value).listen((event) {
        comments.value = event.docs;
      });
    }
  }

  void submit() {
    if (_content.value.isNotEmpty) {
      _isUploading.value = true;
      LikesCommentsService.commentCommentable(
        accountRef: FirebaseAuth.instance.currentUser!.uid,
        commentableRef: _selectedPostRef.value!,
        content: _content.value,
      ).then((value) {
        _content.value = '';
        _isUploading.value = false;
      });
    }
  }
}
