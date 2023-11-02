import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: Get.width,
            height: Get.height * 0.5,
            child: Image.asset(
              "assets/welcome/music_concept_app_welcome_cards.png",
              fit: BoxFit.cover,
              height: Get.height,
              width: Get.width,
            ),
          ),
          Align(
            alignment: const FractionalOffset(0.5, 0.3),
            child: SizedBox(
              width: 150,
              child: Image.asset("assets/logo/logo.png"),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Comparte tus gustos musicales con el mundo",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Con ${AppDefaults.titleName} puedes buscar establecimientos donde se escuche tu musica favorita, mostrar tus gustos musicales y compartir tus listas de reproduccion a todas las personas que quieras",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 50,
                ),
                RoundedButton(
                  onTap: () {
                    Get.toNamed(AppRoutes.login);
                  },
                  label: "Empezar",
                ),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
