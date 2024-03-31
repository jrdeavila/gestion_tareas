import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class HistoryCreatePage extends GetView<CreateHistoryCtrl> {
  final Uint8List? image;
  const HistoryCreatePage({super.key, this.image});

  @override
  Widget build(BuildContext context) {
    controller.setImage(image);
    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          controller.clearAll();
        }
      },
      child: Scaffold(
          appBar: AppBar(
            title: const Text("Crear historia"),
            actions: const [],
          ),
          body: Stack(
            children: [
              _buildForm(context),
              _loadingIndicator(context),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: controller.saveHistory,
            child: const Icon(Icons.send),
          )),
    );
  }

  Widget _loadingIndicator(BuildContext context) {
    return Obx(() {
      if (controller.loading) {
        return Container(
          color: Get.theme.colorScheme.background.withOpacity(0.8),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  SingleChildScrollView _buildForm(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(
          top: kToolbarHeight + 20.0, left: 20.0, right: 20.0, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildImage(context),
          const SizedBox(height: 30.0),
          TextFormField(
            onChanged: controller.setDescription,
            decoration: const InputDecoration(
              hintText: "Escribe una descripción",
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: TextInputType.multiline,
            maxLines: 5,
          ),
        ],
      ),
    );
  }

  Container _buildImage(BuildContext context) {
    return Container(
      height: 300,
      width: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2.0,
        ),
        image: DecorationImage(
          image: MemoryImage(image!),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
