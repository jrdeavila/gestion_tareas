import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:music_concept_app/lib.dart';

class RegisterBussinessPage extends StatelessWidget {
  const RegisterBussinessPage({super.key});

  @override
  Widget build(BuildContext context) {
    var ctrl = Get.find<RegisterBussinessCtrl>();
    ctrl.loadInfo(Get.arguments as Map<String, dynamic>);
    var locationCtrl = Get.find<LocationCtrl>();
    TextEditingController? addressCtrl;
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: [
          const LoginHeader(
            title: "Registrate",
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Obx(() {
                  return ResumeMapLocation(
                    position: ctrl.location ??
                        LatLng(
                          locationCtrl.position!.latitude,
                          locationCtrl.position!.longitude,
                        ),
                    onLocationChange: (place) {
                      ctrl.setLocation(
                        LatLng(
                          place.result!.geometry!.location!.lat!,
                          place.result!.geometry!.location!.lng!,
                        ),
                      );
                      final address =
                          place.result!.formattedAddress ?? place.result!.name!;
                      addressCtrl?.text = address;

                      ctrl.setAddress(address);
                    },
                  );
                }),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    "Presiona el mapa para seleccionar tu ubicacion",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                LoginRoundedTextField(
                  onControllingText: (ctrl) => addressCtrl = ctrl,
                  initialValue: ctrl.address,
                  label: "Direccion",
                  icon: MdiIcons.mapMarker,
                  keyboardType: TextInputType.name,
                  onChanged: ctrl.setAddress,
                  helpText: "Ej: Av. 9 de Octubre y Malecon",
                ),
                LoginDropDownCategories(
                  onChangeCategory: ctrl.setCategory,
                ),
                const SizedBox(
                  height: 20,
                ),
                RoundedButton(
                  label: 'Registrar',
                  onTap: ctrl.submit,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextButton(
                  onPressed: () {
                    Get.offAllNamed(AppRoutes.login);
                  },
                  child: const Text('¿Ya tienes una cuenta? Inicia sesion'),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
