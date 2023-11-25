import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class SettingsPrivacyPage extends StatelessWidget {
  const SettingsPrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.put(PrivacyCtrl(Get.find<FirebaseCtrl>().defaultApp));
    return Scaffold(
        appBar: AppBar(
          title: const Text("Configuracion de privacidad"),
        ),
        body: ListView(
          children: [
            ListTile(
              title: const Text("Foto de perfil"),
              subtitle: const Text(
                "Controla quien puede ver tu foto de perfil",
              ),
              trailing: Obx(() => DropdownPrivacyView(
                    value: controller.profileAvatarVisibility,
                    onChange: (p0) {
                      controller.changeProfileAvatarVisibility(p0);
                    },
                  )),
            ),
            ListTile(
              title: const Text("Privacidad de las publicaciones"),
              subtitle: const Text(
                "Controla quien puede ver tus publicaciones",
              ),
              trailing: DropdownPrivacyView(
                value: SettingsPrivacyView.friends,
                onChange: (p0) {},
              ),
            ),
          ],
        ));
  }
}

class DropdownPrivacyView extends StatelessWidget {
  final ValueChanged<SettingsPrivacyView?> onChange;
  final SettingsPrivacyView? value;
  const DropdownPrivacyView({
    super.key,
    required this.onChange,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<SettingsPrivacyView>(
        value: value,
        onChanged: onChange,
        items: [
          DropdownMenuItem(
            value: SettingsPrivacyView.friends,
            child: Text(privacyViewLabel(SettingsPrivacyView.friends)),
          ),
          DropdownMenuItem(
            value: SettingsPrivacyView.nobody,
            child: Text(privacyViewLabel(SettingsPrivacyView.nobody)),
          ),
          DropdownMenuItem(
            value: SettingsPrivacyView.everyone,
            child: Text(privacyViewLabel(SettingsPrivacyView.everyone)),
          ),
        ]);
  }
}
