import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class UserAppBarAction extends StatelessWidget {
  const UserAppBarAction({
    super.key,
    this.selected = false,
  });

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final HomeCtrl ctrl = Get.find();
    final UserCtrl userCtrl = Get.find();
    return HomeAppBarAction(
      selected: selected,
      onTap: ctrl.currentPage != 2 ? ctrl.goToProfile : null,
      child: PopupMenuButton(
        enabled: ctrl.currentPage == 2,
        offset: const Offset(0, 85.0),
        itemBuilder: (context) {
          return [
            ...userCtrl.userAccounts.entries.map((e) {
              return PopupMenuItem(
                value: e.key,
                child: _buildUserData(e.value),
              );
            }).toList(),
            // Add account
            if (userCtrl.userAccounts.length ==
                AppDefaults.firebaseAuthInstances.length)
              const PopupMenuItem(
                value: 'add',
                child: Row(
                  children: [
                    Icon(MdiIcons.plus),
                    SizedBox(width: 10.0),
                    Text('Añadir cuenta'),
                  ],
                ),
              ),
          ];
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        onSelected: (value) {
          if (value == 'add') {
            userCtrl.addAccount();
          } else {
            userCtrl.changeAccount(value);
          }
        },
        child: Obx(() => _buildUserImage(userCtrl.user)),
      ),
    );
  }

  Widget _buildUserData(DocumentReference<Map<String, dynamic>>? ref) {
    return StreamBuilder(
      stream: ref?.snapshots(),
      builder: (context, snapshot) {
        final name = snapshot.data?.data()?['name'] as String?;
        final image = snapshot.data?.data()?['image'];
        final hasImage = image != null && image.isNotEmpty;
        return Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 30.0,
                height: 30.0,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Get.theme.colorScheme.primary,
                    width: 2.0,
                  ),
                  shape: BoxShape.circle,
                  image: hasImage
                      ? DecorationImage(
                          image: NetworkImage(image),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: hasImage ? null : const Icon(MdiIcons.accountCircle),
              ),
            ),
            const SizedBox(width: 10.0),
            Text(name ?? ''),
          ],
        );
      },
    );
  }

  Widget _buildUserImage(DocumentReference<Map<String, dynamic>>? ref) {
    return StreamBuilder(
        stream: ref?.snapshots(),
        builder: (context, snapshot) {
          final image = snapshot.data?.data()?['image'];
          final hasImage = image != null && image.isNotEmpty;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: hasImage
                    ? DecorationImage(
                        image: NetworkImage(image),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: hasImage ? null : const Icon(MdiIcons.accountCircle),
            ),
          );
        });
  }
}
