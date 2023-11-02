import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class HomeFloatingButton extends StatelessWidget {
  const HomeFloatingButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeCtrl>();
    return Obx(() {
      return TweenAnimationBuilder(
        duration: 500.milliseconds,
        tween: Tween<double>(
          begin: ctrl.showBottomBar ? 1.0 : 0.0,
          end: ctrl.showBottomBar ? 0.0 : 1.0,
        ),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0.0, value * 110.0),
            child: child,
          );
        },
        child: FloatingActionButton.extended(
          onPressed: () {
            Get.find<ActivityCtrl>().resetTimer();
            dialogBuilder<PostType>(
              context,
              Offset(
                Get.width / 2,
                Get.height / 2,
              ),
              const MenuSelectPostOrSurvey(),
            ).then((value) {
              if (value == PostType.survey) {
                Get.toNamed(AppRoutes.createSurvey);
              }
              if (value == PostType.event) {
                showEventDialog(context);
              }
              if (value == PostType.post) {
                showPostDialog(context);
              }
            });
          },
          icon: const Icon(MdiIcons.plus),
          label: const Text('Publicar'),
        ),
      );
    });
  }
}
