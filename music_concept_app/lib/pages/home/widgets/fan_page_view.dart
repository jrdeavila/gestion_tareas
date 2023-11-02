import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class FanPageView extends StatelessWidget {
  const FanPageView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: const Text(AppDefaults.titleName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25.0,
              )),
          actions: [
            HomeAppBarAction(
              selected: true,
              icon: MdiIcons.magnify,
              onTap: () => Get.find<HomeCtrl>().goToSearch(),
            ),
            const SizedBox(width: 10.0),
            Obx(() => NotificationButton(
                  icon: MdiIcons.bell,
                  selected: Get.find<FanPageCtrl>().isNotifications,
                  count: Get.find<NotificationCtrl>().notificationCount,
                  onTap: () {
                    Get.find<FanPageCtrl>().toggleNotifications();
                  },
                )),
            const SizedBox(width: 10.0),
            Obx(() => NotificationButton(
                  selected: Get.find<FanPageCtrl>().isChat,
                  count: Get.find<ChatCtrl>().chatsNotRead,
                  icon: MdiIcons.message,
                  onTap: () => Get.find<FanPageCtrl>().toggleChat(),
                )),
            const SizedBox(width: 16.0),
          ],
        ),
        Expanded(
            child: PageView(
          controller: Get.find<FanPageCtrl>().pageCtrl,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            ReedView(),
            NotificationView(),
            ChatView(),
          ],
        )),
      ],
    );
  }
}
