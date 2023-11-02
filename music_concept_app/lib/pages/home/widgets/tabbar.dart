import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class ProfileTabBar extends StatelessWidget {
  const ProfileTabBar({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 20.0,
      ),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.onBackground,
        borderRadius: BorderRadius.circular(30.0),
      ),
      height: 50,
      child: LayoutBuilder(builder: (context, constriants) {
        final width = constriants.maxWidth / children.length;
        return Row(
          children: children
              .map(
                (e) => SizedBox(
                  width: width,
                  child: e,
                ),
              )
              .toList(),
        );
      }),
    );
  }
}

class ProfileTabBarItem extends StatelessWidget {
  const ProfileTabBarItem({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.find<ActivityCtrl>().resetTimer();
        onTap?.call();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 5.0,
        ),
        height: 40,
        width: double.infinity,
        decoration: BoxDecoration(
          color: selected ? Get.theme.colorScheme.primary : null,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
            ),
            const SizedBox(width: 5.0),
            Text(
              label,
              style: TextStyle(
                color: Get.theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
