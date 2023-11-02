import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class NoWifiCoonnectionPage extends StatelessWidget {
  const NoWifiCoonnectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ConnectionCtrl>();
    return Scaffold(
      body: Obx(() {
        return Center(
          child: SizedBox(
            width: 300,
            height: 450,
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.002)
                        ..scale(1.5)
                        ..translate(
                          0.0,
                          50.0,
                          0.0,
                        ),
                      child: WifiSearchingAnimation(
                        active: ctrl.pining,
                      ),
                    ),
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 500),
                      tween: Tween<double>(
                        begin: 0.0,
                        end: ctrl.pining ? 1.0 : 0.0,
                      ),
                      builder: (context, value, child) {
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..scale(
                              sin(value * pi) * 0.2 + 1.0,
                            )
                            ..rotateZ(sin(value * pi * 3) * 0.1),
                          child: child,
                        );
                      },
                      child: const Text(
                        "Upps! No tenemos conexion a internet",
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40.0),
                    RetryPingingBtn(
                      active: ctrl.pining,
                    )
                  ],
                ),
                if (!ctrl.pining)
                  const Align(
                    alignment: FractionalOffset(0.65, 0.38),
                    child: Icon(
                      MdiIcons.cancel,
                      size: 80,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class RetryPingingBtn extends StatelessWidget {
  final bool active;
  const RetryPingingBtn({
    super.key,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.find<ConnectionCtrl>().ping();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 150,
        height: 60,
        decoration: BoxDecoration(
          color: active ? Get.theme.colorScheme.primary : Colors.transparent,
          border: Border.all(
            color: active ? Get.theme.colorScheme.primary : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            "REINTENTAR",
            style: TextStyle(
                color: !active
                    ? Colors.grey[300]
                    : Get.theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
        ),
      ),
    );
  }
}

class WifiSearchingAnimation extends StatefulWidget {
  final bool active;
  const WifiSearchingAnimation({super.key, this.active = true});

  @override
  State<WifiSearchingAnimation> createState() => _WifiSearchingAnimationState();
}

class _WifiSearchingAnimationState extends State<WifiSearchingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(
        reverse: true,
      );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        const size = 250.0;
        var items = 6;
        return ClipPath(
          clipper: _WifiFormClipper(),
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                ...List.generate(
                  items,
                  (index) => Center(
                    child: _buildCircle(
                      size: size - (index * 50),
                      active:
                          widget.active && index / items >= _controller.value,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCircle({
    required double size,
    required bool active,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: !active ? Colors.grey[300]! : Get.theme.colorScheme.primary,
          width: 14,
        ),
      ),
    );
  }
}

class _WifiFormClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, (size.height / 2) - 10)
      ..lineTo(0, 0);
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return false;
  }
}
