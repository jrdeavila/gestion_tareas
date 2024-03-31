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
        _buildAppBar(),
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

  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage("assets/logo/logo.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 5.0),
          const Text(
            AppDefaults.titleName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
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
    );
  }
}
