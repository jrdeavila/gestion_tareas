import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class MenuSelectPostOrSurvey extends StatelessWidget {
  const MenuSelectPostOrSurvey({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: SizedBox(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Material(
            color: Get.theme.colorScheme.background,
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "¿Que deseas publicar?",
                    style: TextStyle(
                      fontSize: 25.0,
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _listItem(
                          icon: MdiIcons.newspaperVariantMultipleOutline,
                          label: 'Publicacion',
                          onTap: () {
                            Get.back(result: PostType.post);
                          },
                        ),
                        const SizedBox(width: 20.0),
                        _listItem(
                          icon: MdiIcons.poll,
                          label: 'Encuesta',
                          onTap: () {
                            Get.back(result: PostType.survey);
                          },
                        ),
                      ]),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _listItem(
                          icon: MdiIcons.calendar,
                          label: 'Evento',
                          onTap: () {
                            Get.back(result: PostType.event);
                          },
                        ),
                      ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _listItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
            color: Get.theme.colorScheme.onBackground,
            borderRadius: BorderRadius.circular(20.0)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Get.theme.colorScheme.primary,
              size: 70,
            ),
            const SizedBox(
              width: 15.0,
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 20.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showPostDialog(BuildContext context) {
  return dialogKeyboardBuilder(
    context,
    Offset(
      Get.width / 2,
      Get.height / 2,
    ),
    const PostDialogContent(),
  );
}

Future<void> showEventDialog(
  BuildContext context, {
  DocumentSnapshot<Map<String, dynamic>>? event,
}) {
  return dialogKeyboardBuilder(
    context,
    Offset(
      Get.width / 2,
      Get.height / 2,
    ),
    EventDialogContent(
      event: event,
    ),
  );
}
