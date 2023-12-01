import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:music_concept_app/lib.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReedView extends StatelessWidget {
  const ReedView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var posts = Get.find<PostCtrl>().posts;
      var isLoading = Get.find<PostCtrl>().isLoading;
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
          const SliverToBoxAdapter(
            child: BusinessConnection(),
          ),
          posts.isEmpty && isLoading
              ? SliverList(
                  delegate: SliverChildListDelegate([
                    ...List.generate(
                      4,
                      (index) => const PostSkeleton(),
                    ),
                  ]),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      var post = Get.find<PostCtrl>().posts[index];
                      return PostItem(
                        snapshot: post,
                        isReed: true,
                      );
                    },
                    childCount: posts.length,
                    addAutomaticKeepAlives: false,
                  ),
                ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 100.0,
            ),
          ),
          if (!isLoading && posts.isEmpty)
            const SliverToBoxAdapter(
              child: Column(
                children: [
                  Icon(
                    MdiIcons.post,
                    size: 100.0,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    "No hay publicaciones",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ),
        ]),
      );
    });
  }
}

class BusinessConnection extends GetView<UserCtrl> {
  const BusinessConnection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: controller.user?.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.data?['currentVisit'] == null) {
            return const SizedBox.shrink();
          }
          return GestureDetector(
            onTap: () {
              Get.toNamed("");
            },
            child: Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: FutureBuilder(
                  future: UserAccountService.getAccountName(
                      snapshot.data!['currentVisit']),
                  builder: (context, snapshot) {
                    return const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Estas compartiendo en Nombre del establecimiento",
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "¿Desea interactuar con nosotros?",
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    );
                  }),
            ),
          );
        });
  }
}
