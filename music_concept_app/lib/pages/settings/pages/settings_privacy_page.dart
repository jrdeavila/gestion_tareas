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
          title: const Text("Configuración de privacidad"),
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
              title: const Text("Estado en linea"),
              subtitle: const Text(
                "Puedes configurar que personas pueden ver cuando estes en linea",
              ),
              trailing: Obx(() => DropdownPrivacyView(
                    value: controller.profileStatusVisibility,
                    onChange: (p0) {
                      controller.changeProfileStatusVisibility(p0);
                    },
                  )),
            ),
            ListTile(
                title: const Text("Compartiendo en establecimiento"),
                subtitle: const Text(
                  "Puedes configurar que personas pueden ver cuando estes compartiendo en un establecimiento",
                ),
                trailing: Obx(
                  () => DropdownPrivacyView(
                    value: controller.profileBusinessStatusVisibility,
                    onChange: (p0) {
                      controller.changeProfileBusinessStatusVisibility(p0);
                    },
                  ),
                )),
            ListTile(
              title: const Text("Registro de visitas"),
              subtitle: const Text(
                "Controla quien puede ver tu registro de visitas",
              ),
              trailing: Obx(() => DropdownPrivacyView(
                    value: controller.profileTripStatusVisibility,
                    onChange: (p0) {
                      controller.changeProfileTripStatusVisibility(p0);
                    },
                  )),
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
          // DropdownMenuItem(
          //   value: SettingsPrivacyView.friends,
          //   child: Text(privacyViewLabel(SettingsPrivacyView.friends)),
          // ),
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
