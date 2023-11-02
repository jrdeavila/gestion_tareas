import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ResetPasswordCtrl>();
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: [
          const LoginHeader(
            title: "Restablecer contraseña",
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                LoginRoundedTextField(
                  label: "Correo electronico",
                  icon: MdiIcons.email,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: ctrl.setEmail,
                  helpText:
                      "Se enviara un correo electronico para restablecer la contraseña, si no lo encuentras revisa la carpeta de spam",
                ),
                const SizedBox(
                  height: 20,
                ),
                RoundedButton(
                  label: 'Enviar correo',
                  onTap: ctrl.submit,
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
