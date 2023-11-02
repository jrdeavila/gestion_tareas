import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';
import 'package:timeago/timeago.dart' as timeago;

class ShowPostDetailsPage extends StatefulWidget {
  final String postRef;
  const ShowPostDetailsPage({super.key, required this.postRef});

  @override
  State<ShowPostDetailsPage> createState() => _ShowPostDetailsPageState();
}

class _ShowPostDetailsPageState extends State<ShowPostDetailsPage> {
  @override
  void initState() {
    super.initState();
    final ctrl = Get.put(CommentCtrl(
      Get.find<FirebaseCtrl>().defaultApp,
    ));
    ctrl.setSelectedPost(widget.postRef);
  }

  @override
  void dispose() {
    Get.delete<CommentCtrl>();
    super.dispose();
  }

  final _scrollCtrl = ScrollController();
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CommentCtrl>();
    return StreamBuilder(
        stream: ctrl.getPost(widget.postRef),
        builder: (context, snapshot) {
          return Scaffold(
            body: CustomScrollView(
              controller: _scrollCtrl,
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(
                    child: SizedBox(
                  height: kToolbarHeight + 20,
                )),
                SliverToBoxAdapter(
                  child: snapshot.data != null
                      ? PostUserAccountDetails(
                          post: snapshot.data!.data()!,
                          isDetails: true,
                        )
                      : const UserAccountSkeleton(),
                ),
                SliverToBoxAdapter(
                  child: snapshot.data != null
                      ? PostItem(
                          snapshot: snapshot.data!,
                          isReed: true,
                          isDetails: true,
                        )
                      : const PostSkeleton(
                          isResume: true,
                        ),
                ),
                SliverToBoxAdapter(
                    child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _commentField(),
                )),
                Obx(() {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final comment = ctrl.comments[index];
                        return CommentItem(
                          comment: comment,
                        );
                      },
                      childCount: ctrl.comments.length,
                    ),
                  );
                }),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          );
        });
  }

  Widget _commentField() {
    final ctrl = Get.find<CommentCtrl>();
    final commentCtrl = TextEditingController();
    return Obx(() {
      return TextFormField(
        controller: commentCtrl,
        onChanged: ctrl.setContent,
        decoration: InputDecoration(
            filled: true,
            fillColor: Get.theme.colorScheme.onBackground,
            hintText: "Escribe una respuesta ...",
            suffixIconConstraints: const BoxConstraints(
              maxHeight: 40,
              maxWidth: 60,
            ),
            suffixIcon: ctrl.isUploading
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: LoadingIndicator(),
                  )
                : Center(
                    child: GestureDetector(
                      onTap: () {
                        ctrl.submit();
                        commentCtrl.clear();
                      },
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(20),
            )),
      );
    });
  }
}

class CommentItem extends StatelessWidget {
  final DocumentSnapshot<Map<String, dynamic>> comment;
  const CommentItem({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CommentCtrl>();
    return StreamBuilder(
        stream: ctrl.getAccount(comment.data()!["accountRef"]),
        builder: (context, snapshot) {
          final name = snapshot.data?["name"] ?? "";
          final image = snapshot.data?["image"];
          return Container(
            width: 140.0,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _commentContent(image, name),
                _commentActions(),
              ],
            ),
          );
        });
  }

  Transform _commentActions() {
    final ctrl = Get.find<CommentCtrl>();
    return Transform.scale(
      scale: 0.8,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 10),
          StreamBuilder(
              stream: ctrl.getCommentLikes(
                commentRef: comment.reference.path,
              ),
              builder: (context, likes) {
                return StreamBuilder(
                    stream:
                        ctrl.isLikedComment(commentRef: comment.reference.path),
                    builder: (context, snapshot) {
                      return PostAction(
                        label: likes.data?.toString() ?? "0",
                        onTap: () {
                          if (snapshot.data == true) {
                            ctrl.dislikeComment(
                                commentRef: comment.reference.path);
                          } else {
                            ctrl.likeComment(
                                commentRef: comment.reference.path);
                          }
                        },
                        selected: snapshot.data ?? false,
                        selectedIcon: MdiIcons.heart,
                        icon: MdiIcons.heartOutline,
                      );
                    });
              }),
          const SizedBox(
            width: 10.0,
          ),
          Expanded(
            child: Text(
                timeago.format(
                  comment.data()?['createdAt'] != null
                      ? (comment.data()!['createdAt'] as Timestamp).toDate()
                      : DateTime.now(),
                  locale: 'es',
                ),
                style: const TextStyle(fontSize: 18.0)),
          )
        ],
      ),
    );
  }

  Row _commentContent(String? image, String? name) {
    final hasImage = image != null;
    final hasName = name != null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: hasImage
              ? CachingImage(
                  fit: BoxFit.cover,
                  url: image,
                  width: 40,
                  height: 40,
                )
              : const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.onBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              hasName
                  ? Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    )
                  : Container(
                      width: 100,
                      height: 20,
                      color: Colors.grey[300],
                    ),
              const SizedBox(height: 4),
              Text(
                comment.data()!["content"],
                style: const TextStyle(
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
