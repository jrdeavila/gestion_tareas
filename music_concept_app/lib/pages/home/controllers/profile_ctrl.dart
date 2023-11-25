import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class ProfileCtrl extends GetxController {
  final FirebaseApp _app;

  ProfileCtrl(this._app);

  FirebaseAuth get _authApp => FirebaseAuth.instanceFor(app: _app);

  final RxList<String> wallpapers = RxList();
  final Rx<String?> _selectedWallpaper = Rx<String?>(null);

  String get selectedWallpaper => _selectedWallpaper.value ?? "fondo_1.jpg";

  Stream<DocumentSnapshot<Map<String, dynamic>>> getAccountStream(
      [String? accountRef]) {
    return UserAccountService.getUserAccountDoc(
      accountRef ?? "users/${_authApp.currentUser?.uid}",
    ).snapshots();
  }

  Stream<List<String>> getFollowingInCurrentVisit({
    required String? accountRef,
  }) =>
      BusinessService.getFollingInCurrentVisit(
        accountRef: accountRef ?? "users/${_authApp.currentUser!.uid}",
      );

  Stream<List<FdSnapshot>> getBusinessVisits({
    required String? accountRef,
  }) =>
      BusinessService.getBusinessVisits(
        accountRef: accountRef ?? "users/${_authApp.currentUser!.uid}",
      );

  Stream<List<FdSnapshot>> getVisitors({
    required String? accountRef,
  }) =>
      BusinessService.getVisitors(
        businessRef: accountRef ?? "users/${_authApp.currentUser!.uid}",
      );

  Stream<bool> isAFriend({
    required String accountRef,
  }) {
    return FollowingFollowersServices.accountIsFriend(
        accountRef: accountRef, userRef: "users/${_authApp.currentUser!.uid}");
  }

  Stream<List<String>> getFollowers(String? accountRef) {
    return FollowingFollowersServices.getFollowers(
        accountRef: accountRef ?? "users/${_authApp.currentUser!.uid}");
  }

  Stream<List<String>> getFollowings(String? accountRef) {
    return FollowingFollowersServices.getFollowings(
        accountRef: accountRef ?? "users/${_authApp.currentUser!.uid}");
  }

  Stream<List<String>> getFriends(String? accountRef) {
    return FollowingFollowersServices.getFriends(
        accountRef: accountRef ?? "users/${_authApp.currentUser!.uid}");
  }

  @override
  void onReady() {
    super.onReady();
    _loadWallpapers();
    _selectedWallpaper.listen((value) {
      BackgroundService.setBackground(
        "users/${_authApp.currentUser?.uid}",
        value,
      );
    });
  }

  Stream<int> getFollowersCount(String? accountRef) {
    return FollowingFollowersServices.getFollowersCount(accountRef);
  }

  Stream<int> getFollowingCount(String? accountRef) {
    return FollowingFollowersServices.getFollowingCount(accountRef);
  }

  Stream<int> getPostsCount(String? accountRef) {
    return PostService.getAccountPostsCount(accountRef);
  }

  Stream<bool> isFollowing({
    required String followerRef,
    required String followingRef,
  }) {
    return FollowingFollowersServices.isFollowing(
      followerRef: followerRef,
      followingRef: followingRef,
    );
  }

  void follows({
    required String followerRef,
    required String followingRef,
  }) {
    FollowingFollowersServices.followAccount(
      followerRef: followerRef,
      followingRef: followingRef,
    );
  }

  void unfollow({
    required String followerRef,
    required String followingRef,
  }) {
    FollowingFollowersServices.unfollowAccount(
      followerRef: followerRef,
      followingRef: followingRef,
    );
  }

  void selectWallpaper(String? wallpaper) {
    _selectedWallpaper.value = wallpaper;
  }

  void _loadWallpapers() async {
    // Lee el contenido de la carpeta "assets/images"
    String manifestContent = await rootBundle.loadString('AssetManifest.json');
    Map<String, dynamic> manifestMap = json.decode(manifestContent);

    // Recorre el mapa para obtener la lista de imágenes
    for (String key in manifestMap.keys) {
      if (key.contains('assets/wallpapers')) {
        wallpapers.add(key);
      }
    }
  }

  void addAcademicStudy(String value) {
    UserAccountService.addAcademicStudy(
      accountRef: "users/${_authApp.currentUser!.uid}",
      value: value,
    );
  }

  void removeAcademicStudy(String value) {
    UserAccountService.removeAcademicStudy(
      accountRef: "users/${_authApp.currentUser!.uid}",
      value: value,
    );
  }

  void changeMaritalStatus({
    required String value,
    required String? accountRef,
  }) {
    UserAccountService.changeMaritalStatus(
      accountRef: accountRef ?? "users/${_authApp.currentUser!.uid}",
      value: value,
    );
  }

  void changeAvatar(Uint8List image) {
    UserAccountService.changeAvatar(
      accountRef: _authApp.currentUser!.uid,
      image: image,
    );
  }

  void changeCustomWallpaper(Uint8List uint8list) {
    UserAccountService.changeWallpaper(
      accountRef: _authApp.currentUser!.uid,
      image: uint8list,
    );
  }
}

final accountOptions = {
  'view-profile-details': {
    "label": "Ver perfil",
    "icon": MdiIcons.account,
    "onTap": (TapUpDetails details, BuildContext context) {
      Get.toNamed(AppRoutes.profileDetails);
      return;
    },
  },
  'settings-app': {
    "label": "Configuración de la aplicación",
    "icon": MdiIcons.cog,
    "onTap": (TapUpDetails details, BuildContext context) {
      Get.toNamed(AppRoutes.settings);
      return;
    },
  },
  "settings-privacy": {
    "label": "Configuración de la cuenta",
    "icon": MdiIcons.accountCog,
    "onTap": (TapUpDetails details, BuildContext context) {
      Get.toNamed(AppRoutes.settingsPrivacy);
      return;
    },
  },
};

int accountTypeIndex(UserAccountType type) {
  return UserAccountType.values.indexOf(type);
}
