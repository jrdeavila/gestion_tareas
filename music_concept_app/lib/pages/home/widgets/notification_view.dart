import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Notificaciones (${Get.find<NotificationCtrl>().notificationCount})",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                  color: Colors.grey[500],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    var notification =
                        Get.find<NotificationCtrl>().notifications[index];
                    return NotificationItem(notification: notification);
                  },
                  itemCount: Get.find<NotificationCtrl>().notifications.length,
                ),
              ),
              SizedBox(
                height: 80,
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Get.find<NotificationCtrl>().deleteAll();
                        },
                        child: const SizedBox(
                          height: double.infinity,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(MdiIcons.deleteOutline),
                              SizedBox(width: 10.0),
                              Text("Borrar todo"),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                        child: InkWell(
                      onTap: () {
                        Get.find<NotificationCtrl>().markAllAsRead();
                      },
                      child: const SizedBox(
                        height: double.infinity,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(MdiIcons.bellOffOutline),
                            SizedBox(width: 10.0),
                            Text("Marcar como leído"),
                          ],
                        ),
                      ),
                    ))
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
