import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController? emailCtrl, passwordCtrl, nameCtrl;
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RegisterCtrl>();
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Obx(
          () => Column(
            children: [
              const SizedBox(
                height: 200,
                child: LoginHeader(
                  title: "Registrate",
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ProfileTabBar(children: [
                  ProfileTabBarItem(
                    label: "Credenciales",
                    icon: MdiIcons.accountLock,
                    selected: ctrl.page == 0,
                    onTap: () {
                      emailCtrl?.text = ctrl.email;
                      passwordCtrl?.text = ctrl.password;
                      ctrl.previousPage();
                      setState(() {});
                    },
                  ),
                  ProfileTabBarItem(
                    label: "Datos personales",
                    icon: MdiIcons.account,
                    selected: ctrl.page == 1,
                    onTap: () {
                      nameCtrl?.text = ctrl.name;
                      ctrl.nextPage();
                      setState(() {});
                    },
                  ),
                ]),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                child:
                    ctrl.page == 0 ? _credentialsForm() : _personalInfoForm(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 80,
        child: Center(
          child: TextButton(
            onPressed: () {
              Get.offAllNamed(AppRoutes.login);
            },
            child: const Text('¿Ya tienes una cuenta? Inicia sesion'),
          ),
        ),
      ),
    );
  }

  Widget _personalInfoForm() {
    final ctrl = Get.find<RegisterCtrl>();
    return Column(
      children: [
        Center(
          child: SizedBox(
            width: 150,
            height: 150,
            child: ImagePicker(
              onImageSelected: ctrl.setImage,
            ),
          ),
        ),
        LoginRoundedTextField(
          onControllingText: (ctrl) {
            nameCtrl = ctrl;
          },
          label: "Nombre",
          icon: MdiIcons.account,
          keyboardType: TextInputType.name,
          onChanged: ctrl.setName,
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RoundedButton(
            onTap: () {
              ctrl.submit();
            },
            label: "Continuar como persona",
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RoundedButton(
            padding: EdgeInsets.zero,
            onTap: () {
              ctrl.goToBussiness();
            },
            label: "Continuar como negocio",
            isBordered: true,
          ),
        ),
      ],
    );
  }

  Widget _credentialsForm() {
    var ctrl = Get.find<RegisterCtrl>();
    return Column(
      children: [
        LoginRoundedTextField(
          label: "Correo electronico",
          icon: MdiIcons.email,
          keyboardType: TextInputType.emailAddress,
          onChanged: ctrl.setEmail,
          onControllingText: (ctrl) {
            emailCtrl = ctrl;
          },
        ),
        LoginRoundedTextField(
          label: "Contraseña",
          icon: MdiIcons.lock,
          keyboardType: TextInputType.visiblePassword,
          isPassword: true,
          onChanged: ctrl.setPassword,
          onControllingText: (ctrl) {
            passwordCtrl = ctrl;
          },
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RoundedButton(
            onTap: () {
              ctrl.nextPage();
            },
            label: "Continuar",
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
