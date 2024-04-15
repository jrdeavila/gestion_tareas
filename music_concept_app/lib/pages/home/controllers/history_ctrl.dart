import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class HistoryCameraCtrl extends GetxController {
  final RxBool _loadingCamera = true.obs;
  final Rx<List<CameraDescription>> _cameras = Rx([]);
  late final Rx<CameraController> _cameraController;
  final RxBool _flashOn = false.obs;
  final Rx<Uint8List?> _image = Rx(null);

  // ====================================================

  CameraController get cameraController => _cameraController.value;
  bool get loadingCamera => _loadingCamera.value;
  bool get flashOn => _flashOn.value;
  bool get hasImage => _image.value != null;
  Uint8List? get image => _image.value;

  // ====================================================

  @override
  void onReady() {
    super.onReady();
    initializeCamera();
  }

  @override
  void dispose() {
    _image.value = null;
    _cameras.value = [];
    _cameraController.value.dispose();
    super.dispose();
  }

  // ====================================================

  void takePicture() async {
    _loadingCamera.value = true;
    final image = await cameraController.takePicture();
    _image.value = await image.readAsBytes();
    await Future.delayed(const Duration(seconds: 1));
    _loadingCamera.value = false;
  }

  void findOnGallery() async {
    PickImageUtility.pickImage().then((value) {
      if (value != null) {
        _image.value = value;
      }
    });
  }

  Future<void> initializeCamera() async {
    _loadingCamera.value = true;

    final cameras = await availableCameras();
    _cameras.value = cameras;

    _cameraController = Rx(CameraController(cameras[0], ResolutionPreset.max));

    await _cameraController.value.dispose();
    _cameraController.value =
        CameraController(cameras[0], ResolutionPreset.medium);
    await Future.delayed(const Duration(seconds: 1));
    _cameraController.value.initialize().then((value) {
      _loadingCamera.value = false;
    }).catchError((error) {
      SnackbarUtils.showSnackbar(
        message: "Error al inicializar la cámara",
        label: "Re intentar",
      );
    });
    await cameraController.setFlashMode(FlashMode.off);
  }

  void switchCamera() async {
    _loadingCamera.value = true;
    final lensDirection = cameraController.description.lensDirection;
    late CameraDescription newDescription;
    if (lensDirection == CameraLensDirection.front) {
      newDescription = _cameras.value[0];
    } else {
      newDescription = _cameras.value[1];
    }

    await cameraController.dispose();
    _cameraController.value = CameraController(
      newDescription,
      ResolutionPreset.medium,
    );
    await cameraController.initialize();
    _loadingCamera.value = false;
  }

  void toggleFlash() async {
    final flashMode = cameraController.value.flashMode;
    if (flashMode == FlashMode.off) {
      await cameraController.setFlashMode(FlashMode.torch);
    } else {
      await cameraController.setFlashMode(FlashMode.off);
    }
    _flashOn.value = cameraController.value.flashMode == FlashMode.torch;
    _flashOn.refresh();
  }

  void discardImage() {
    _image.value = null;
  }

  void saveImage() {
    final image = _image.value;
    if (image != null) {
      Get.toNamed(AppRoutes.historyCreate, arguments: image);
    }
  }
}

class CreateHistoryCtrl extends GetxController {
  final FirebaseApp _app;
  // ====================================================
  CreateHistoryCtrl(this._app);
  // ====================================================
  final Rx<Uint8List?> _images = Rx(null);
  final RxString _description = "".obs;
  final RxBool _loading = false.obs;
  // ====================================================

  Uint8List? get images => _images.value;
  String get description => _description.value;
  bool get loading => _loading.value;

  // ====================================================

  void setDescription(String value) {
    _description.value = value;
  }

  void setImage(Uint8List? image) {
    _images.value = image;
  }

  // ====================================================

  void saveHistory() async {
    _loading.value = true;
    var history = History(
      id: TimeUtils.generateDateId(),
      imageBytes: _images.value!,
      userCreatorId: FirebaseAuth.instanceFor(app: _app).currentUser!.uid,
      description: _description.value,
      createdAt: DateTime.now(),
    );
    try {
      history = await (HistoryService.createHistory(history));
      _loading.value = false;
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      SnackbarUtils.showSnackbar(
        message: "Error al guardar la historia",
        label: "Re intentar",
      );
      _loading.value = false;
    }
  }

  void clearAll() {
    _description.value = "";
    _images.value = null;
    _loading.value = false;
  }
}

class HistoryCtrl extends GetxController {
  final FirebaseApp _app;

  HistoryCtrl(this._app);

  // ====================================================

  final RxMap<UserCreator, List<History>> _histories =
      <UserCreator, List<History>>{}.obs;

  // ====================================================

  Map<UserCreator, List<History>> get histories => _histories;

  // ====================================================

  @override
  void onReady() {
    super.onReady();
    _fetchHistories();
  }

  // ====================================================

  Future<void> _fetchHistories() async {
    final userId = FirebaseAuth.instanceFor(app: _app).currentUser!.uid;
    try {
      final myHistories = await HistoryService.getMyHistory(userId);
      if (myHistories.isNotEmpty && myHistories.first.userCreator != null) {
        _histories[myHistories.first.userCreator!] = myHistories;
      }
      final histories =
          await HistoryService.getHistoriesFromFollowingUsers(userId);
      _histories.assignAll({
        ..._histories,
        ...histories,
      });

      _histories.refresh();
    } catch (e) {
      print(e);
    }
  }

  // ====================================================
  void onCreateHistory() {
    Get.toNamed(AppRoutes.historyCamera);
  }

  void showOptions(History history) {
    Get.bottomSheet(
      HistoryOptions(history: history),
      isScrollControlled: true,
    );
  }

  void deleteHistory(History history) async {
    final res = await HistoryService.deleteHistory(history);
    if (!res) {
      SnackbarUtils.showSnackbar(
        message: "Error al eliminar la historia",
        label: "Re intentar",
      );
      return;
    }
    _histories[history.userCreator!]!.removeWhere(
      (element) => element.id == history.id,
    );
    if (_histories[history.userCreator!]!.isEmpty) {
      _histories.remove(history.userCreator!);
    }
    _histories.refresh();
    Get.offAllNamed(AppRoutes.home);
  }

  void showHistory(UserCreator userCreator) {
    Get.bottomSheet(
      ShowHistory(
        userCreator: userCreator,
      ),
      isScrollControlled: true,
    );
  }

  Future<void> refreshData() async {
    await _fetchHistories();
  }
}
