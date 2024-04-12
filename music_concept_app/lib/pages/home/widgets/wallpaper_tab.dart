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
      return Column(
        children: [
          ImagePicker(
            onImageSelected: (image) {
              if (image != null) {
                ctrl.changeCustomWallpaper(image);
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 10.0,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 30.0,
              ),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wallpaper,
                    size: 30.0,
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      'Agregar Fondo personalizado',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: MasonryGridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate:
                  const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5.0,
                  ),
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
            ),
          ),
        ],
      );
    });
  }
}
