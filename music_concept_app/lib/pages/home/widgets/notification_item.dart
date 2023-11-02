import 'package:music_concept_app/lib.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationItem extends StatelessWidget {
  const NotificationItem({
    super.key,
    required this.notification,
  });

  final FdSnapshot notification;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onLongPress: () {
        Get.find<NotificationCtrl>()
            .deleteNotification(notification.reference.path);
      },
      onTap: () {
        Get.find<NotificationCtrl>().markAsRead(notification.reference.path);
        Get.toNamed(
          AppRoutes.postDetails,
          arguments: notification["arguments"]!['ref'],
        );
      },
      leading: notificationIcon[notification["type"]]!,
      minLeadingWidth: 10.0,
      minVerticalPadding: 10.0,
      title: Text(
        notification["title"],
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          overflow: TextOverflow.ellipsis,
        ),
        maxLines: 2,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification["body"],
            style: const TextStyle(
              fontSize: 14.0,
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 2,
          ),
          Text(
            TimeUtils.timeagoFormat(notification["createdAt"].toDate()),
            style: const TextStyle(
              fontSize: 12.0,
            ),
          )
        ],
      ),
      trailing: notification["read"] == false
          ? Container(
              width: 10.0,
              height: 10.0,
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}
