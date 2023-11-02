import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostItem extends StatefulWidget {
  const PostItem({
    super.key,
    required this.snapshot,
    this.isReed = false,
    this.isDetails = false,
  });

  final DocumentSnapshot<Map<String, dynamic>> snapshot;
  final bool isReed;
  final bool isDetails;

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  @override
  void initState() {
    super.initState();
    Get.lazyPut(() => FollowerEditSurveyItemsCtrl());
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PostCtrl>();

    Map<String, dynamic> post = widget.snapshot.data()!;
    bool hasImage = post['image'] != null;
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 360,
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: widget.isDetails
              ? Get.theme.colorScheme.background
              : Get.theme.colorScheme.onBackground,
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasImage) _buildImage(post),
                if (!widget.isDetails) PostUserAccountDetails(post: post),
                if (post['type'] == PostType.event.index)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ResumeSelectDate(
                      readOnly: true,
                      date: post['startDate']?.toDate(),
                      children: [
                        Text(
                          post['content'] ?? '',
                          style: const TextStyle(
                            fontSize: 22.0,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                      ],
                    ),
                  ),
                if (post['type'] != PostType.event.index)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 20.0),
                    child: Text(
                      post['content'] ?? '',
                      style: TextStyle(
                        fontSize: hasImage ? 18.0 : 22.0,
                      ),
                    ),
                  ),
                if (post['type'] == "survey" ||
                    post["type"] == PostType.survey.index) ...[
                  _buildSurveyOptionsStream(ctrl, post),
                  if (post['allowAddOptions'] ?? false) _buildAddNewOption(),
                ],
                const SizedBox(height: 20.0),
                _buildPostDetails(post),
              ],
            ),
            if (!widget.isReed) _buildPostMenu(),
          ],
        ),
      ),
    );
  }

  Positioned _buildPostMenu() {
    final ctrl = Get.find<PostCtrl>();
    return Positioned(
      right: 0,
      top: 0,
      child: PopupMenuProfile(
        icon: MdiIcons.dotsVertical,
        positionY: 0,
        selected: false,
        options: {
          'edit': {
            "label": "Editar",
            "icon": MdiIcons.pencil,
            "onTap": () {
              showEventDialog(
                context,
                event: widget.snapshot,
              );
            },
          },
          'delete': {
            "label": "Eliminar",
            "icon": MdiIcons.trashCan,
            "onTap": () {
              ctrl.deletePost(widget.snapshot.reference.path);
            },
          },
        },
      ),
    );
  }

  Row _buildPostDetails(Map<String, dynamic> post) {
    final ctrl = Get.find<PostCtrl>();
    var isNotExpired =
        (post['startDate'] as Timestamp?)?.toDate().isAfter(DateTime.now()) ??
            false;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        StreamBuilder<bool>(
            stream: ctrl.accountLikedPost(
              postRef: widget.snapshot.reference.path,
            ),
            builder: (context, snapshot) {
              return StreamBuilder<int>(
                  stream: ctrl.countLikesPost(
                    postRef: widget.snapshot.reference.path,
                  ),
                  builder: (context, likes) {
                    return PostAction(
                        label: likes.data?.toString() ?? "0",
                        selected: snapshot.data ?? false,
                        selectedIcon: MdiIcons.heart,
                        icon: MdiIcons.heartOutline,
                        onTap: () {
                          if (snapshot.data == true) {
                            ctrl.dislikePost(
                                postRef: widget.snapshot.reference.path);
                          } else {
                            ctrl.likePost(
                                postRef: widget.snapshot.reference.path);
                          }
                        });
                  });
            }),
        StreamBuilder<int>(
            stream: ctrl.countCommentsPost(
              postRef: widget.snapshot.reference.path,
            ),
            builder: (context, snapshot) {
              return PostAction(
                selected: false,
                label: snapshot.data?.toString() ?? "0",
                icon: MdiIcons.commentOutline,
                selectedIcon: MdiIcons.comment,
                onTap: () {
                  Get.toNamed(
                    AppRoutes.postDetails,
                    arguments: widget.snapshot.reference.path,
                  );
                },
              );
            }),
        if (post['type'] == PostType.event.index && isNotExpired)
          StreamBuilder<int>(
              stream: Get.find<EventCtrl>().getCountAssist(
                eventRef: widget.snapshot.reference.id,
              ),
              builder: (context, count) {
                return StreamBuilder<bool>(
                    stream: Get.find<EventCtrl>().hasAssistOnEvent(
                      eventRef: widget.snapshot.reference.id,
                    ),
                    builder: (context, assist) {
                      return PostAction(
                        label:
                            "${count.data ?? 0}  ${assist.data == false ? 'Asistiras?' : ''}",
                        onTap: () {
                          if (assist.data == false) {
                            Get.find<EventCtrl>().assistEvent(
                              eventRef: widget.snapshot.reference.id,
                            );
                          } else {
                            Get.find<EventCtrl>().deleteAssistEvent(
                              eventRef: widget.snapshot.reference.id,
                            );
                          }
                        },
                        selected: assist.data ?? false,
                        selectedIcon: MdiIcons.account,
                        icon: MdiIcons.accountOutline,
                      );
                    });
              })
      ],
    );
  }

  ClipRRect _buildImage(Map<String, dynamic> post) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      ),
      child: CachingImage(
        url: post['image'],
        height: 200,
        fit: BoxFit.cover,
        width: double.infinity,
      ),
    );
  }

  Obx _buildAddNewOption() {
    final flwItemCtrl = Get.find<FollowerEditSurveyItemsCtrl>()
      ..setCurrentOptions(widget.snapshot.reference.id);
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (flwItemCtrl.isNew)
              SurveyItemWithRemove(
                hint: "Nueva opción",
                value: flwItemCtrl.content,
                image: flwItemCtrl.image,
                onChanged: (value) {
                  flwItemCtrl.onChange(value);
                },
                onImageChange: (value) {
                  flwItemCtrl.onChangeImage(value);
                },
                onRemove: () {
                  flwItemCtrl.removeItem();
                },
              ),
            !flwItemCtrl.isNew
                ? AddNewSurveyItemButton(
                    onTap: () {
                      flwItemCtrl.addItem();
                    },
                  )
                : flwItemCtrl.hasContent
                    ? GestureDetector(
                        onTap: () {
                          flwItemCtrl.submit();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Get.theme.colorScheme.primary,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 10.0,
                          ),
                          height: 45.0,
                          width: double.infinity,
                          child: const Center(
                            child: Text(
                              "Agregar Opcion",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
          ],
        ),
      );
    });
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> _buildSurveyOptionsStream(
      PostCtrl ctrl, Map<String, dynamic> post) {
    return StreamBuilder(
        stream: ctrl.getOptions(widget.snapshot.id),
        builder: (context, snapshot) {
          return StreamBuilder<int>(
              stream: ctrl.getTopOption(widget.snapshot.id),
              builder: (context, snapshotTop) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  child: Column(
                    children: [
                      if (post["allowMultipleVotes"] ?? false) ...[
                        ...List.generate(snapshot.data?.docs.length ?? 0,
                            (index) {
                          final option = snapshot.data!.docs[index];
                          return CheckSurveyItem(
                              surveyRef: widget.snapshot.id,
                              snapshot: option,
                              maxVotes: snapshotTop.data ?? 0);
                        }),
                      ] else ...[
                        ...List.generate(snapshot.data?.docs.length ?? 0,
                            (index) {
                          final option = snapshot.data!.docs[index];
                          return RadioSurveyItem(
                              surveyRef: widget.snapshot.id,
                              snapshot: option,
                              maxVotes: snapshotTop.data ?? 0);
                        }),
                      ],
                    ],
                  ),
                );
              });
        });
  }
}

class PostAction extends StatelessWidget {
  const PostAction({
    super.key,
    required this.label,
    required this.onTap,
    required this.selected,
    required this.selectedIcon,
    required this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;
  final IconData selectedIcon;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final Color foreground = selected
        ? Get.theme.colorScheme.primary
        : Get.theme.colorScheme.onBackground;
    return GestureDetector(
      onTap: () {
        Get.find<ActivityCtrl>().resetTimer();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Row(
          children: [
            Icon(
              selected ? selectedIcon : icon,
              color: selected ? foreground : null,
            ),
            const SizedBox(width: 5.0),
            Text(
              label,
              style: TextStyle(
                color: selected ? foreground : null,
                fontSize: 18.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostUserAccountDetails extends StatelessWidget {
  const PostUserAccountDetails({
    super.key,
    required this.post,
    this.isDetails = false,
  });

  final Map<String, dynamic> post;
  final bool isDetails;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PostCtrl>();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 10.0,
      ),
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: ctrl.getAccountRef(post['accountRef']),
          builder: (context, snapshot) {
            var hasActiveStatus =
                snapshot.data?.data()?.containsKey("active") ?? false;
            return GestureDetector(
              onTap: () {
                if (snapshot.hasData) {
                  Get.find<FanPageCtrl>().goToGuestProfile(snapshot.data!);
                }
              },
              child: Row(
                children: [
                  ProfileImage(
                    hasVisit: snapshot.data?.data()?["currentVisit"] != null,
                    active: hasActiveStatus &&
                        (snapshot.data?.data()?["active"] ?? false),
                    image: snapshot.data?['image'],
                    name: snapshot.data?['name'],
                    avatarSize: isDetails ? 60.0 : 40.0,
                    fontSize: isDetails ? 30.0 : 20.0,
                  ),
                  const SizedBox(width: 10.0),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot.data?['name'] ?? '',
                        style: TextStyle(
                          fontSize: isDetails ? 25.0 : 16.0,
                        ),
                      ),
                      Row(
                        children: [
                          if (post['createdAt'] != null)
                            Text(
                              timeago.format(
                                post['createdAt']?.toDate(),
                                locale: 'es',
                              ),
                              style: TextStyle(
                                fontSize: isDetails ? 16.0 : 12.0,
                                color: Colors.grey,
                              ),
                            ),
                          const SizedBox(width: 5.0),
                          Icon(
                            getVisibilityIcon(post['visibility']),
                            size: 12.0,
                            color: Colors.grey,
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            );
          }),
    );
  }
}
