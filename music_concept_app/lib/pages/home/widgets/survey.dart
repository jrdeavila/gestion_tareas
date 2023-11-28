import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class AddNewSurveyItemButton extends StatelessWidget {
  const AddNewSurveyItemButton({
    super.key,
    this.onTap,
  });

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50.0,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.onBackground,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: Colors.grey[800]!,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.add, color: Colors.grey[500]!),
            const SizedBox(width: 10.0),
            Text(
              "Agregar una opción de respuesta ...",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SurveyItem extends StatelessWidget {
  const SurveyItem({
    super.key,
    required this.hint,
    this.image,
    required this.onChangeText,
    required this.onChangeImage,
    this.value,
  });

  final String hint;
  final String? value;
  final Uint8List? image;
  final void Function(String) onChangeText;
  final void Function(Uint8List?) onChangeImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.onBackground,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10.0),
          const CustomCheckBox(
            disabled: true,
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: TextFormField(
              initialValue: value,
              onChanged: onChangeText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                hintText: hint,
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            width: 1,
            color: Colors.grey[800],
          ),
          ImagePicker(
            image: image,
            margin: 0,
            onImageSelected: onChangeImage,
            childOnImageSelected: (image, child) => image != null
                ? Container(
                    margin: const EdgeInsets.all(5.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7.0),
                      child: Image.memory(
                        image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : child,
            child: Container(
              margin: const EdgeInsets.all(10.0),
              child: Icon(
                MdiIcons.imageArea,
                color: Colors.grey[500]!,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CustomCheckBox extends StatelessWidget {
  const CustomCheckBox({
    super.key,
    this.checked = false,
    this.onTap,
    this.disabled = false,
  });

  final bool checked;
  final bool disabled;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled
          ? null
          : () {
              onTap?.call();
            },
      child: Container(
          height: 20,
          width: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: checked ? Get.theme.colorScheme.primary : null,
            border: Border.all(
              color:
                  checked ? Get.theme.colorScheme.primary : Colors.grey[500]!,
              width: 2.0,
            ),
          ),
          child: checked
              ? const Icon(
                  MdiIcons.checkBold,
                  color: Colors.white,
                  size: 15.0,
                )
              : null),
    );
  }
}

class MeltingIceCreamDropClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0.0, size.height - 40);

    path.quadraticBezierTo(
        size.width / 4, size.height - 80, size.width / 2, size.height - 40);

    path.quadraticBezierTo(size.width - (size.width / 4), size.height,
        size.width, size.height - 40);

    path.lineTo(size.width, 0.0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class RadioSurveyItem extends StatelessWidget {
  const RadioSurveyItem({
    super.key,
    required this.snapshot,
    required this.maxVotes,
    required this.surveyRef,
  });

  final DocumentSnapshot<Map<String, dynamic>> snapshot;
  final int maxVotes;
  final String surveyRef;

  @override
  Widget build(BuildContext context) {
    final option = snapshot.data()!;
    final ctrl = Get.find<PostCtrl>();
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              StreamBuilder<bool>(
                  stream: ctrl.accountHasAnswerOption(
                      optionRef: snapshot.reference.id, surveyRef: surveyRef),
                  builder: (context, snapshotBool) {
                    return Radio<String?>(
                      value: snapshotBool.data == true
                          ? snapshot.reference.id
                          : null,
                      groupValue: snapshot.reference.id,
                      onChanged: (value) {
                        ctrl.changeSurveyAnswer(
                          surveyRef: surveyRef,
                          optionRef: snapshot.reference.id,
                        );
                      },
                    );
                  }),
              Expanded(
                child: SurveyProgressInfo(
                  option: option,
                  surveyRef: surveyRef,
                  snapshot: snapshot,
                  maxVotes: maxVotes,
                ),
              ),
            ],
          ),
          // Votos
        ],
      ),
    );
  }
}

class CheckSurveyItem extends StatelessWidget {
  const CheckSurveyItem({
    super.key,
    required this.snapshot,
    required this.maxVotes,
    required this.surveyRef,
  });

  final DocumentSnapshot<Map<String, dynamic>> snapshot;
  final int maxVotes;
  final String surveyRef;

  @override
  Widget build(BuildContext context) {
    final option = snapshot.data()!;
    final ctrl = Get.find<PostCtrl>();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              StreamBuilder<bool>(
                  stream: ctrl.accountHasAnswerOption(
                      optionRef: snapshot.reference.id, surveyRef: surveyRef),
                  builder: (context, snapshotBool) {
                    return CustomCheckBox(
                      checked: snapshotBool.data ?? false,
                      onTap: () {
                        if (snapshotBool.data == false) {
                          ctrl.createSurveyAnwser(
                              surveyRef: surveyRef,
                              optionRef: snapshot.reference.id);
                        } else {
                          ctrl.deleteSurveyAnwser(
                            surveyRef: surveyRef,
                            optionRef: snapshot.reference.id,
                          );
                        }
                      },
                    );
                  }),
              const SizedBox(width: 15.0),
              Expanded(
                child: SurveyProgressInfo(
                  option: option,
                  surveyRef: surveyRef,
                  snapshot: snapshot,
                  maxVotes: maxVotes,
                ),
              ),
            ],
          ),
          // Votos
        ],
      ),
    );
  }
}

class SurveyProgressInfo extends StatelessWidget {
  const SurveyProgressInfo({
    super.key,
    required this.option,
    required this.surveyRef,
    required this.snapshot,
    required this.maxVotes,
  });

  final Map<String, dynamic> option;
  final String surveyRef;
  final DocumentSnapshot<Map<String, dynamic>> snapshot;
  final int maxVotes;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PostCtrl>();
    return LayoutBuilder(builder: (context, constraints) {
      var hasImage = option["image"] != null;
      return Container(
        height: hasImage ? 100 : 45,
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.primary.withOpacity(0.3),
          borderRadius: const BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        child: Stack(
          children: [
            StreamBuilder<int>(
                stream: ctrl.getOptionAnswerCount(
                  surveyRef: surveyRef,
                  optionRef: snapshot.id,
                ),
                builder: (context, snapshot) {
                  final votes = snapshot.data ?? 0;
                  var percent = (votes / maxVotes);
                  return Container(
                    width: constraints.maxWidth.isNaN
                        ? 0
                        : constraints.maxWidth * (percent.isNaN ? 0 : percent),
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.primary,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                  );
                }),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 10.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (hasImage) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: GestureDetector(
                              onTap: () {
                                Get.to(() => ImagePreviewPage(
                                    imageUrl: option['image']));
                              },
                              child: CachingImage(
                                url: option['image'],
                                height: 30,
                                width: 30,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10.0),
                        ],
                        Expanded(
                          child: Text(
                            option['option'],
                            style: const TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        StreamBuilder<int>(
                            stream: ctrl.getOptionAnswerCount(
                              surveyRef: surveyRef,
                              optionRef: snapshot.id,
                            ),
                            builder: (context, snapshot) {
                              final votes = snapshot.data ?? 0;

                              return Text(
                                "$votes votos",
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            })
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
