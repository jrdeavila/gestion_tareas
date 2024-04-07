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
        child: RefreshIndicator(
          onRefresh: Get.find<HomeCtrl>().refreshData,
          child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(
                  child: BusinessConnection(),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 250,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Historias recientes",
                          style: TextStyle(fontSize: 18.0),
                        ),
                        SizedBox(height: 16.0),
                        Expanded(
                          child: HistorySection(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Divider(
                    color: Colors.grey,
                    height: 40.0,
                  ),
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
        ),
      );
    });
  }
}

class HistorySection extends GetView<HistoryCtrl> {
  const HistorySection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ListView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          const CreateHistoryCard(),
          ...controller.histories.entries
              .map((e) => HistoryCard(
                    histories: e.value,
                    userCreator: e.key,
                  ))
              .toList(),
        ],
      );
    });
  }
}

class HistoryCard extends GetView<HistoryCtrl> {
  const HistoryCard({
    super.key,
    required this.histories,
    required this.userCreator,
  });

  final List<History> histories;
  final UserCreator userCreator;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.showHistory(userCreator);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(20.0),
        ),
        margin: const EdgeInsets.only(right: 16.0),
        width: 150.0,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: CachingImage(
                height: double.infinity,
                fit: BoxFit.cover,
                url: histories.first.imageUrl!,
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: ProfileImage(
                image: userCreator.imageUrl,
                name: userCreator.name,
                avatarSize: 40.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateHistoryCard extends GetView<HistoryCtrl> {
  const CreateHistoryCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.onCreateHistory,
      child: Container(
        margin: const EdgeInsets.only(right: 16.0),
        width: 150.0,
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.onBackground,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 80),
            Text(
              "Nueva historia",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
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
          if (snapshot.data?.data()?['currentVisit'] == null) {
            return const SizedBox.shrink();
          }
          return GestureDetector(
            onTap: () {},
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
