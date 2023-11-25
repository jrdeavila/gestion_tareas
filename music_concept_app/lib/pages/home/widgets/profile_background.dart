import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class BackgroundProfile extends StatefulWidget {
  const BackgroundProfile({
    super.key,
    required this.scrollCtrl,
    required this.documentRef,
  });

  final ScrollController scrollCtrl;
  final DocumentReference<Map<String, dynamic>>? documentRef;

  @override
  State<BackgroundProfile> createState() => _BackgroundProfileState();
}

class _BackgroundProfileState extends State<BackgroundProfile> {
  double _backgroundOpacity = 1.0;

  @override
  void initState() {
    super.initState();

    widget.scrollCtrl.addListener(() {
      _backgroundOpacity = 1 - (widget.scrollCtrl.offset / 50).clamp(0, 1);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProfileCtrl>();

    return StreamBuilder(
        stream: ctrl.getAccountStream(
          widget.documentRef?.path,
        ),
        builder: (context, snapshot) {
          final hasBackground = snapshot.data?.data()?['background'] != null;
          final hasCustomBackground =
              snapshot.data?.data()?['wallpaper'] != null;
          dynamic background = AssetImage(
              snapshot.data?.data()?['background'] ?? ctrl.selectedWallpaper);

          return Opacity(
            opacity: _backgroundOpacity,
            child: hasCustomBackground
                ? CachedNetworkImage(
                    imageUrl: snapshot.data?.data()?['wallpaper'],
                    fit: BoxFit.cover,
                  )
                : Container(
                    margin: const EdgeInsets.only(
                      top: kToolbarHeight - 20,
                    ),
                    decoration: BoxDecoration(
                      image: hasBackground
                          ? DecorationImage(
                              image: background,
                              fit: BoxFit.cover,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
          );
        });
  }
}
