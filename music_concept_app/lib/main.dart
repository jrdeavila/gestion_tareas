import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:music_concept_app/lib.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() async {
  runZonedGuarded(
    () async {
      FlutterNativeSplash.remove();
      WidgetsFlutterBinding.ensureInitialized();

      await GetStorage.init();

      initializeDateFormatting('es');
      timeago.setLocaleMessages('es', timeago.EsMessages());

      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          // statusBarIconBrightness: Brightness.dark,
          // systemNavigationBarColor: Colors.transparent,
          // systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );

      Get.putAsync(() async {
        final apps = await Future.wait([
          Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          ...AppDefaults.firebaseAuthInstances.map(
            (e) => Firebase.initializeApp(
              name: e,
              options: DefaultFirebaseOptions.currentPlatform,
            ),
          ),
        ]);
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.debug,
        );
        return FirebaseCtrl(apps);
      });

      Get.lazyPut(() => LocationCtrl());
      Get.lazyPut(() => LoginCtrl());
      Get.lazyPut(() => RegisterCtrl());
      Get.lazyPut(() => ResetPasswordCtrl());
      Get.lazyPut(() => RegisterBussinessCtrl());

      runApp(const MyApp());
    },
    HandlerException.handler,
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: const Locale("es"),
      debugShowCheckedModeBanner: false,
      title: AppDefaults.titleName,
      routes: AppRoutes.routes,
      initialRoute: AppRoutes.root,
      theme: ColorPalete.themeData,
    );
  }
}
