import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';
import 'package:url_launcher/url_launcher.dart';

class YourMusicTabView extends StatelessWidget {
  final String? accountRef;
  const YourMusicTabView({super.key, required this.accountRef});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20.0),
          const Text(
            "Canciones que has escuchado recientemente",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20.0),
          Expanded(
            child: FutureBuilder(
                future:
                    Get.find<SpotifyCtrl>().getRecentlyPlayedTracks(accountRef),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: List.generate(
                        5,
                        (index) => const TrackItemSkeleton(),
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.done &&
                      (snapshot.data?.isEmpty ?? false)) {
                    return const Center(
                      child: Text("No hay canciones recientes"),
                    );
                  }
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      var item = snapshot.data![index];
                      return TrackItem(
                        item: item,
                      );
                    },
                    itemCount: snapshot.data?.length ?? 0,
                  );
                }),
          ),
        ],
      ),
    );
  }
}

class TrackItem extends StatelessWidget {
  const TrackItem({super.key, required this.item});

  final SpotifyTrack item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.onBackground,
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.all(10.0),
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          if (item.imageURL != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: CachingImage(
                url: item.imageURL!,
                width: 50,
                height: 50,
              ),
            ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item.artist,
                  style: const TextStyle(
                    fontSize: 15.0,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 10.0,
          ),
          HomeAppBarAction(
            onTap: () {
              launchUrl(Uri.parse(item.trackURL));
            },
            icon: MdiIcons.chevronDoubleRight,
          ),
        ],
      ),
    );
  }
}

class TrackItemSkeleton extends StatefulWidget {
  const TrackItemSkeleton({super.key});

  @override
  State<TrackItemSkeleton> createState() => _TrackItemSkeletonState();
}

class _TrackItemSkeletonState extends State<TrackItemSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.onBackground,
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.all(10.0),
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          SkeletonBox(
            width: 50.0,
            height: 50.0,
            radius: 10.0,
            value: _animationController.value,
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  width: 100.0,
                  height: 15.0,
                  value: _animationController.value,
                ),
                const SizedBox(height: 5.0),
                SkeletonBox(
                  width: 100.0,
                  height: 10.0,
                  value: _animationController.value,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
