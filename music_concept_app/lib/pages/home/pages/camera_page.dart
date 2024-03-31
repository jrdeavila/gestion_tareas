import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class HistoryCameraView extends GetView<HistoryCameraCtrl> {
  const HistoryCameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loadingCamera) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      return PopScope(
        canPop: !controller.hasImage,
        onPopInvoked: (didPop) {
          if (!didPop) {
            controller.discardImage();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (!controller.hasImage) _buildCameraView(),
            if (controller.hasImage) _buildImageView(),
          ],
        ),
      );
    });
  }

  Scaffold _buildImageView() {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.memory(
              controller.image!,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: kToolbarHeight + 20.0,
            left: 20.0,
            child: HomeAppBarAction(
              icon: Icons.close,
              onTap: () {
                controller.discardImage();
              },
            ),
          ),
          Positioned(
            bottom: 20.0,
            left: 20.0,
            right: 20.0,
            child: HomeAppBarAction(
              light: true,
              selected: true,
              icon: Icons.check,
              onTap: () {
                controller.saveImage();
              },
            ),
          ),
        ],
      ),
    );
  }

  Scaffold _buildCameraView() {
    final cameraController = controller.cameraController;
    return Scaffold(
      body: Center(
        child: SizedBox(
          child: CameraPreview(
            cameraController,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  controller.switchCamera();
                },
                icon: const Icon(Icons.flip_camera_ios),
              ),
              GestureDetector(
                onTap: () {
                  controller.takePicture();
                },
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(
                    Icons.camera,
                    color: Get.theme.colorScheme.primary,
                    size: 50.0,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  controller.toggleFlash();
                },
                icon: Icon(
                  controller.flashOn ? Icons.flash_on : Icons.flash_off,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
