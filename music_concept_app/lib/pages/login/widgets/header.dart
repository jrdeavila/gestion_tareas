import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 50,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(100),
        ),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: Get.theme.colorScheme.onPrimary,
            fontSize: 50,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
