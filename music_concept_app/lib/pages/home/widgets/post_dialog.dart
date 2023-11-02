import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class PostDialogContent extends StatefulWidget {
  const PostDialogContent({
    super.key,
  });

  @override
  State<PostDialogContent> createState() => _PostDialogContentState();
}

class _PostDialogContentState extends State<PostDialogContent> {
  @override
  void initState() {
    super.initState();
    Get.lazyPut(() => CreatePostCtrl(Get.find<FirebaseCtrl>().defaultApp));
  }

  @override
  void dispose() {
    Get.delete<CreatePostCtrl>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CreatePostCtrl>();
    return Obx(() {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: SizedBox(
          width: Get.width * 0.8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Material(
              color: Get.theme.colorScheme.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (ctrl.image == null) _headDialog(),
                  if (ctrl.image != null)
                    SizedBox(
                        height: 200,
                        child: Image.memory(
                          ctrl.image!,
                          fit: BoxFit.cover,
                        )),
                  const SizedBox(height: 20.0),
                  TextField(
                    minLines: 5,
                    maxLines: 7,
                    style: const TextStyle(
                      fontSize: 18.0,
                    ),
                    decoration: const InputDecoration(
                      hintText: '¿Que estas pensando?',
                      hintStyle: TextStyle(),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 15.0),
                    ),
                    onChanged: ctrl.setContent,
                  ),
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ImagePicker(
                          onImageSelected: ctrl.setImage,
                          child: Icon(
                            MdiIcons.videoImage,
                            color: Get.theme.colorScheme.primary,
                            size: 35.0,
                          ),
                        ),
                        const Spacer(),
                        DropDownVisibility(onChange: ctrl.setVisibility),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RoundedButton(
                        onTap: ctrl.isUploading ? null : ctrl.submit,
                        radius: 20.0,
                        label: ctrl.isUploading ? null : 'Publicar',
                        child: ctrl.isUploading
                            ? Center(
                                child: LoadingIndicator(
                                  size: 25.0,
                                  count: 4,
                                  color: Get.theme.colorScheme.onPrimary,
                                ),
                              )
                            : null),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Padding _headDialog() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Crear publicación',
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              HomeAppBarAction(
                selected: true,
                icon: MdiIcons.close,
                onTap: () {
                  Get.back();
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}

class DropDownVisibility extends StatelessWidget {
  const DropDownVisibility({
    super.key,
    required this.onChange,
    this.fontSize = 12.0,
  });

  final Function(PostVisibility p1) onChange;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150 * (fontSize / 12.0),
      child: DropdownButtonFormField(
          style: TextStyle(
            fontSize: fontSize,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Get.theme.colorScheme.onBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15.0),
          ),
          value: PostVisibility.public,
          items: postOptions
              .map(
                (key, value) => MapEntry(
                  key,
                  DropdownMenuItem(
                    value: key,
                    child: Row(
                      children: [
                        Icon(value['icon'] as IconData, size: 18.0),
                        const SizedBox(width: 5.0),
                        Text(value['label'] as String),
                      ],
                    ),
                  ),
                ),
              )
              .values
              .toList(),
          onChanged: (value) {}),
    );
  }
}
