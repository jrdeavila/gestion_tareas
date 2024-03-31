import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

abstract class AppRoutes {
  // Rutas de la aplicacion
  static const String settings = "/settings";

  // Rutas del cliente
  static const String login = "/login";
  static const String register = "/register";
  static const String resetPassword = "/reset-password";

  // Rutas del negocio
  static const String businessRegister = "/business-register";
  static const String createSurvey = "/create-survey";
  static const String mapsFindLocation = "/map-find-location";
  static const String mapsViewLocation = "/maps-view-location";
  static const String mapsViewBusiness = "/maps-view-business";

  static const String home = "/home";
  static const String notWifi = "/not-wifi";
  static const String root = "/";
  static const String postDetails = "/post-details";
  static const String guestProfile = "/guest-profile";
  static const String chat = "/chat";
  static const String followers = "/followers";
  static const String profileDetails = '/profile-details';
  static const String settingsPrivacy = '/settings-privacy';

  static const String historyCamera = "/camera";
  static const String historyCreate = "/history-create";

  static const String initialRoute = root;
  static final Map<String, Widget Function(BuildContext context)> routes = {
    root: (context) => const WelcomePage(),
    settings: (context) => const SettingsPage(),
    login: (context) => const LoginPage(),
    register: (context) => const RegisterPage(),
    businessRegister: (context) => const RegisterBussinessPage(),
    mapsFindLocation: (context) => const MapFindLocationPage(),
    mapsViewLocation: (context) =>
        MapsViewLocationPage(guest: Get.arguments as FdSnapshot),
    mapsViewBusiness: (context) => const MapsViewBusinessPage(),
    createSurvey: (context) => const CreateSurvePage(),
    postDetails: (context) => ShowPostDetailsPage(postRef: Get.arguments),
    resetPassword: (context) => const ResetPasswordPage(),
    home: (context) => const HomePage(),
    notWifi: (context) => const NoWifiCoonnectionPage(),
    guestProfile: (context) => GuestProfilePage(guest: Get.arguments),
    chat: (context) => ChatPage(conversationRef: Get.arguments),
    followers: (context) => FollowersPage(guest: Get.arguments),
    profileDetails: (context) => ProfileDetailsPage(guest: Get.arguments),
    settingsPrivacy: (context) => const SettingsPrivacyPage(),
    historyCamera: (context) => const HistoryCameraView(),
    historyCreate: (context) => HistoryCreatePage(image: Get.arguments),
  };
}
