import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class WallpaperTabView extends StatelessWidget {
  const WallpaperTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProfileCtrl>();
    return Obx(() {
      return MasonryGridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemBuilder: (context, index) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
            child: GestureDetector(
              onTap: () {
                ctrl.selectWallpaper(ctrl.wallpapers[index]);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image.asset(
                  ctrl.wallpapers[index],
                  height: index.isEven ? 200 : 150,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
        itemCount: ctrl.wallpapers.length,
      );
    });
  }
}
