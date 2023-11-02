import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class CreateSurvePage extends StatefulWidget {
  const CreateSurvePage({super.key});

  @override
  State<CreateSurvePage> createState() => _CreateSurvePageState();
}

class _CreateSurvePageState extends State<CreateSurvePage> {
  final _scrollCtrl = ScrollController();
  double _clipperOpacity = 1.0;
  @override
  void initState() {
    super.initState();
    Get.lazyPut(() => CreateSurverCtrl());
    _scrollCtrl.addListener(() {
      _clipperOpacity = 1 - (_scrollCtrl.offset / 100).clamp(0, 1);
      setState(() {});
    });
  }

  @override
  void dispose() {
    Get.delete<CreateSurverCtrl>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CreateSurverCtrl>();
    return Scaffold(
      body: Obx(() {
        return Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              height: 320.0,
              child: Opacity(
                opacity: _clipperOpacity,
                child: ClipPath(
                  clipper: MeltingIceCreamDropClipper(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    width: double.infinity,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomScrollView(
                  controller: _scrollCtrl,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      floating: true,
                      toolbarHeight: 100,
                      backgroundColor: Colors.transparent,
                      leadingWidth: 76,
                      leading: HomeAppBarAction(
                        light: true,
                        icon: Icons.arrow_back,
                        selected: true,
                        onTap: () => Get.back(),
                      ),
                      title: const Text('Publicar Encuesta'),
                    ),
                    ...[
                      TextField(
                        minLines: 3,
                        maxLines: 3,
                        maxLength: 100,
                        cursorColor: Get.theme.colorScheme.onPrimary,
                        style: const TextStyle(
                          fontSize: 25.0,
                        ),
                        decoration: const InputDecoration(
                          hintText: '¿De que trata tu encuesta?',
                          hintStyle: TextStyle(
                            fontSize: 25.0,
                          ),
                          border: InputBorder.none,
                        ),
                        onChanged: ctrl.setContent,
                      ),
                      const SizedBox(height: 10.0),
                      const Text(
                        "Opciones de la encuesta",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      ...List.generate(
                        ctrl.options.length,
                        (index) => SurveyItemWithRemove(
                          hint: "Opcion ${index + 1}",
                          value: ctrl.options[index]["value"],
                          onChanged: (value) {
                            ctrl.onChangeByIndex(index, value);
                          },
                          onImageChange: (value) {
                            ctrl.onChangeImageByIndex(index, value);
                          },
                          onRemove: () {
                            ctrl.removeItem(index);
                          },
                        ),
                      ),
                      AddNewSurveyItemButton(
                        onTap: () {
                          Get.find<CreateSurverCtrl>().addItem();
                        },
                      ),
                      const SizedBox(height: 30.0),
                      const Text(
                        "Configuracion de la encuesta",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      _configItem(
                        label: "Permitir que los usuarios agreguen opciones",
                        value: ctrl.allowAddOptions,
                        onChanged: () => ctrl.setAllowAddOptions(),
                      ),
                      const Divider(),
                      _configItem(
                        label: "Permitir multiples votos",
                        value: ctrl.allowMultipleVotes,
                        onChanged: () => ctrl.setAllowMultipleVotes(),
                      ),
                      const Divider(),
                    ].map((e) => SliverToBoxAdapter(child: e)),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DropDownVisibility(
              fontSize: 16.0,
              onChange: ctrl.setVisibility,
            ),
            Obx(() {
              return RoundedButton(
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
                      : null);
            }),
          ],
        ),
      ),
    );
  }

  Widget _configItem({
    required String label,
    required bool value,
    required void Function() onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          const SizedBox(width: 15.0),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          CustomCheckBox(
            checked: value,
            onTap: onChanged,
          ),
        ],
      ),
    );
  }
}

class SurveyItemWithRemove extends StatelessWidget {
  final String hint;
  final String value;
  final Uint8List? image;
  final void Function(String) onChanged;
  final void Function(Uint8List?) onImageChange;
  final void Function() onRemove;

  const SurveyItemWithRemove({
    super.key,
    required this.hint,
    required this.value,
    this.image,
    required this.onChanged,
    required this.onImageChange,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Expanded(
            child: SurveyItem(
              value: value,
              hint: hint,
              image: image,
              onChangeText: onChanged,
              onChangeImage: onImageChange,
            ),
          ),
          const SizedBox(width: 10.0),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              height: 50.0,
              width: 50.0,
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.onBackground,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: Colors.grey[800]!,
                  width: 1.0,
                ),
              ),
              child: Icon(
                Icons.delete,
                color: Colors.grey[500]!,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
