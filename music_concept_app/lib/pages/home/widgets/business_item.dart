import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class BusinessItem extends StatelessWidget {
  const BusinessItem({
    super.key,
    required this.item,
    required this.isBusiness,
  });

  final FdSnapshot item;
  final bool isBusiness;

  @override
  Widget build(BuildContext context) {
    var ref = isBusiness
        ? (item.data()?['businessRef'])
        : (item.data()?['accountRef']);
    return StreamBuilder(
        stream: Get.find<ProfileCtrl>().getAccountStream(ref),
        builder: (context, snapshot) {
          if (snapshot.data == null) return const BusinessItemSkeleton();

          return GestureDetector(
            onTap: () {
              if (snapshot.hasData) {
                Get.toNamed(AppRoutes.guestProfile, arguments: snapshot.data);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10.0),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.onBackground,
                borderRadius: BorderRadius.circular(20.0),
              ),
              width: 120,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ProfileImage(
                    image: snapshot.data?['image'],
                    name: snapshot.data?['name'],
                    avatarSize: 60.0,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(snapshot.data!['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    TimeUtils.timeagoFormat(
                      item['createdAt'].toDate(),
                    ),
                    style: TextStyle(
                      color: Get.theme.colorScheme.primary,
                      fontSize: 12.0,
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}

class BusinessItemSkeleton extends StatelessWidget {
  const BusinessItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10.0),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.onBackground,
        borderRadius: BorderRadius.circular(20.0),
      ),
      width: 120,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SkeletonBox(
            width: 60.0,
            height: 60.0,
            shape: BoxShape.circle,
            value: 1,
          ),
          const SizedBox(
            height: 10.0,
          ),
          SkeletonBox(
            width: 80,
            height: 10,
            value: 1,
            borderRadius: BorderRadius.circular(5.0),
          ),
          const SizedBox(
            height: 10.0,
          ),
          SkeletonBox(
            width: 50,
            height: 8.0,
            value: 1,
            borderRadius: BorderRadius.circular(5.0),
          )
        ],
      ),
    );
  }
}
