import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de la app'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modo ignconito
              _incognitoSwitch(),
              const SizedBox(height: 16),

              Text(
                "Configuración de localización",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                ),
              ),
              _locationSwitch(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _incognitoSwitch() {
    final ctrl = Get.find<LocationCtrl>();
    return Obx(() {
      return ListTile(
        selected: ctrl.incognitoMode,
        leading: const Icon(MdiIcons.incognito),
        title: const Text('Modo incógnito'),
        subtitle: const Text(
            'Utiliza la app sin localización, nadie sabrá a donde estuviste.'),
        trailing: Switch(
          value: ctrl.incognitoMode,
          onChanged: (value) {
            ctrl.toggleIngcognitoMode();
          },
        ),
      );
    });
  }

  Widget _locationSwitch() {
    final ctrl = Get.find<LocationCtrl>();
    return Obx(() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            selected: ctrl.hasPermissions,
            leading: const Icon(MdiIcons.mapMarker),
            title: const Text('Ubicación'),
            subtitle: const Text('Permitir acceso a la ubicación'),
            trailing: ctrl.permissionsBlocked
                ? TextButton(
                    onPressed: () {
                      ctrl.goToSettings();
                    },
                    child: const Text('Permitir'),
                  )
                : Switch(
                    value: ctrl.hasPermissions,
                    onChanged: (value) {
                      ctrl.requestPermissions();
                    },
                  ),
          ),
        ],
      );
    });
  }
}
