import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class HistoryCtrl extends GetxController {
  final FirebaseApp _app;

  HistoryCtrl(this._app);

  // ====================================================

  final RxList<History> _histories = <History>[].obs;
  final RxBool _loadingCamera = false.obs;
  final Rx<CameraController> _cameraController = Rx(CameraController(
      Get.find<List<CameraDescription>>()[0], ResolutionPreset.max));

  // ====================================================

  List<History> get histories => _histories;
  CameraController get cameraController => _cameraController.value;
  bool get loadingCamera => _loadingCamera.value;
  // ====================================================

  @override
  void onReady() {
    super.onReady();
    _fetchHistories();
  }

  // ====================================================

  Future<void> _fetchHistories() async {
    final userId = FirebaseAuth.instanceFor(app: _app).currentUser!.uid;
    final histories =
        await HistoryService.getHistoriesFromFollowingUsers(userId);
    _histories.assignAll(histories);
  }

  // TODO: Implementar la consulta de historias del usuario
  // ====================================================
  void onCreateHistory() {
    Get.toNamed(AppRoutes.historyCamera);
  }

  Future<void> _createHistory(
      {required String title, required Uint8List image}) async {
    final userId = FirebaseAuth.instanceFor(app: _app).currentUser!.uid;
    var history = History(
      title: title,
      imageBytes: image,
      userCreatorId: userId,
      createdAt: DateTime.now(),
    );
    history = await HistoryService.createHistory(history);
  }

  // ====================================================

  void toggleFlash() {
    final flashMode = cameraController.value.flashMode;
    if (flashMode == FlashMode.off) {
      cameraController.setFlashMode(FlashMode.torch);
    } else {
      cameraController.setFlashMode(FlashMode.off);
    }
  }

  void takePicture() async {
    final image = await cameraController.takePicture();
    // TODO: Implementar la creación de la historia
  }

  Future<void> initializeCamera() async {
    _loadingCamera.value = true;
    await _cameraController.value.dispose();
    _cameraController.value = CameraController(
        Get.find<List<CameraDescription>>()[0], ResolutionPreset.medium);
    await Future.delayed(const Duration(seconds: 1));
    _cameraController.value.initialize().then((value) {
      _loadingCamera.value = false;
    }).catchError((error) {
      print(error);
      SnackbarUtils.showSnackbar(
        message: "Error al inicializar la cámara",
        label: "Re intentar",
      );
    });
    await cameraController.setFlashMode(FlashMode.off);
  }

  void disposeCamera() {
    cameraController.dispose();
  }

  void switchCamera() {
    final lensDirection = cameraController.description.lensDirection;
    if (lensDirection == CameraLensDirection.front) {
      _cameraController.value = CameraController(
          Get.find<List<CameraDescription>>()[1], ResolutionPreset.medium);
    } else {
      _cameraController.value = CameraController(
          Get.find<List<CameraDescription>>()[0], ResolutionPreset.medium);
    }
    cameraController.initialize();
  }
}
