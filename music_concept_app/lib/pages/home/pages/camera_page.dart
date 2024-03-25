import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class HistoryCameraView extends StatefulWidget {
  const HistoryCameraView({super.key});

  @override
  State<HistoryCameraView> createState() => _HistoryCameraViewState();
}

class _HistoryCameraViewState extends State<HistoryCameraView> {
  @override
  void initState() {
    super.initState();

    Get.find<HistoryCtrl>().initializeCamera();
  }

  @override
  void dispose() {
    Get.find<HistoryCtrl>().disposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraController = Get.find<HistoryCtrl>().cameraController;
    return Scaffold(
      body: Obx(() {
        if (Get.find<HistoryCtrl>().loadingCamera) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return AspectRatio(
          aspectRatio: (cameraController.value.previewSize?.height ?? 1) /
              (cameraController.value.previewSize?.width ?? 1),
          child: Stack(
            children: [
              CameraPreview(
                cameraController,
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        Get.find<HistoryCtrl>().takePicture();
                      },
                      icon: const Icon(Icons.camera_alt),
                      iconSize: 40,
                      color: Colors.white,
                    ),
                    IconButton(
                      onPressed: () {
                        Get.find<HistoryCtrl>().switchCamera();
                      },
                      icon: const Icon(Icons.switch_camera),
                      iconSize: 40,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
