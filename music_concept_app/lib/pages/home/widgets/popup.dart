import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class PopupMenuProfile extends StatelessWidget {
  const PopupMenuProfile({
    super.key,
    required this.options,
    required this.icon,
    this.selected = true,
    this.positionY = 85.0,
  });

  final Map<String, dynamic> options;
  final IconData icon;
  final double positionY;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      offset: Offset(0, positionY),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      onOpened: () {
        Get.find<ActivityCtrl>().resetTimer();
      },
      onCanceled: () {
        Get.find<ActivityCtrl>().resetTimer();
      },
      onSelected: (value) {
        (options[value]!['onTap'] as VoidCallback)();
      },
      itemBuilder: (context) {
        return options.keys
            .map((e) => PopupMenuItem(
                  value: e,
                  child: Row(
                    children: [
                      Icon(options[e]!['icon'] as IconData?),
                      const SizedBox(width: 10.0),
                      Text(options[e]!['label'] as String),
                    ],
                  ),
                ))
            .toList();
      },
    );
  }
}
