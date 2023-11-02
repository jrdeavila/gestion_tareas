import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class NotificationButton extends StatelessWidget {
  const NotificationButton({
    super.key,
    required this.onTap,
    required this.count,
    required this.selected,
    required this.icon,
  });

  final VoidCallback onTap;
  final int count;
  final bool selected;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return HomeAppBarAction(
      selected: true,
      light: selected,
      onTap: onTap,
      child: Center(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: selected ? Get.theme.colorScheme.primary : null,
              ),
            ),
            if (count > 0)
              Align(
                alignment: Alignment.center,
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 10.0,
                    color: selected
                        ? Get.theme.colorScheme.onPrimary
                        : Get.theme.colorScheme.onBackground,
                  ),
                ),
              ),
            if (count > 0)
              Positioned(
                top: 13,
                right: 13,
                child: Container(
                  width: 10.0,
                  height: 10.0,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
