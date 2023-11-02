import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class LoginRoundedTextField extends StatefulWidget {
  const LoginRoundedTextField({
    super.key,
    required this.label,
    this.icon,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.isPassword = false,
    this.helpText,
    this.onControllingText,
  });

  final String label;
  final IconData? icon;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final bool isPassword;
  final String? helpText;
  final String? initialValue;
  final void Function(TextEditingController)? onControllingText;

  @override
  State<LoginRoundedTextField> createState() => _LoginRoundedTextFieldState();
}

class _LoginRoundedTextFieldState extends State<LoginRoundedTextField> {
  late bool _visible;
  late TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _visible = widget.isPassword;
    _controller = TextEditingController(text: widget.initialValue);
    widget.onControllingText?.call(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: TextFormField(
        enabled: widget.onChanged != null,
        controller: _controller,
        obscureText: _visible,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          prefixIcon: widget.icon != null
              ? Icon(widget.icon, color: Get.theme.colorScheme.primary)
              : null,
          suffixIcon: widget.isPassword ? _toggleVisibilityWidget() : null,
          hintText: widget.label,
          helperText: widget.helpText,
          helperMaxLines: 3,
          fillColor: Get.theme.colorScheme.onBackground,
          filled: true,
          border: OutlineInputBorder(
            gapPadding: 12,
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _toggleVisibilityWidget() => GestureDetector(
        onTap: () => setState(() => _visible = !_visible),
        child: Icon(_visible ? MdiIcons.eye : MdiIcons.eyeOff),
      );
}

class LoginDropDownCategories extends StatelessWidget {
  const LoginDropDownCategories({
    super.key,
    this.onChangeCategory,
  });

  final void Function(String)? onChangeCategory;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RegisterBussinessCtrl>();
    return Obx(() {
      final categories = ctrl.categories;
      return Container(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButtonFormField(
          decoration: InputDecoration(
            fillColor: Get.theme.colorScheme.onBackground,
            filled: true,
            hintText: 'Categoria',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            prefixIcon:
                Icon(MdiIcons.music, color: Get.theme.colorScheme.primary),
          ),
          items: categories
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              onChangeCategory?.call(value.toString());
            }
          },
        ),
      );
    });
  }
}
