import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ctrl = Get.find<HomeCtrl>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        ctrl.goToReed();
        return false;
      },
      child: Scaffold(
        endDrawer: const HomeDrawer(),
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          controller: ctrl.pageCtrl,
          children: const [
            SearchPageView(),
            FanPageView(), // Home View
            ProfileView(), // Profile View
          ],
        ),
        extendBody: true,
        floatingActionButton: const HomeFloatingButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: const HomeBottomBar(),
      ),
    );
  }
}

class HomeFloatingButton extends StatelessWidget {
  const HomeFloatingButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeCtrl>();
    return Obx(() {
      return TweenAnimationBuilder(
        duration: 500.milliseconds,
        tween: Tween<double>(
          begin: ctrl.showBottomBar ? 1.0 : 0.0,
          end: ctrl.showBottomBar ? 0.0 : 1.0,
        ),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0.0, value * 110.0),
            child: child,
          );
        },
        child: FloatingActionButton.extended(
          onPressed: () {
            Get.find<ActivityCtrl>().resetTimer();
            dialogBuilder<PostType>(
              context,
              Offset(
                Get.width / 2,
                Get.height / 2,
              ),
              const MenuSelectPostOrSurvey(),
            ).then((value) {
              if (value == PostType.survey) {
                Get.toNamed(AppRoutes.createSurvey);
              }
              if (value == PostType.event) {
                showEventDialog(context);
              }
              if (value == PostType.post) {
                showPostDialog(context);
              }
            });
          },
          icon: const Icon(MdiIcons.plus),
          label: const Text('Publicar'),
        ),
      );
    });
  }
}

class HomeBottomBar extends StatelessWidget {
  const HomeBottomBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeCtrl>();
    return Obx(() {
      return TweenAnimationBuilder(
        duration: 300.milliseconds,
        tween: Tween<double>(
          begin: ctrl.showBottomBar ? 1.0 : 0.0,
          end: ctrl.showBottomBar ? 0.0 : 1.0,
        ),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0.0, value * 80.0),
            child: child,
          );
        },
        child: ClipPath(
          clipper: _RoundedBottomAppBarClipper(),
          child: BottomAppBar(
            color: Get.theme.primaryColor,
            height: 80.0,
            child: Row(children: [
              const SizedBox(width: 16.0),
              HomeAppBarAction(
                selected: ctrl.currentPage == 1,
                icon: MdiIcons.home,
                onTap: () {
                  ctrl.goToReed();
                },
              ),
              const Spacer(),
              UserAppBarAction(
                selected: ctrl.currentPage == 2,
              ),
              const SizedBox(width: 16.0),
            ]),
          ),
        ),
      );
    });
  }
}

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
            const PopupMenuItem(
              value: null,
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
          if (value == null) {
            Get.toNamed(AppRoutes.register);
          } else {
            Get.find<HomeCtrl>().goToProfile();
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

class _RoundedBottomAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final x = size.width;
    final y = size.height;
    const r = 20.0;
    const r2 = 35.0;
    const p = 8.0;
    const n = 70.0;
    const b = 28.0;

    final path = Path()
      ..moveTo(0, p + r)
      ..quadraticBezierTo(0, p, r, p)
      ..lineTo((x / 2) - n, 0)
      ..quadraticBezierTo(
        (x / 2) - n,
        b,
        (x / 2) + r2 - n,
        b,
      )
      ..lineTo((x / 2) + n - r2, b)
      ..quadraticBezierTo(
        (x / 2) + n,
        b,
        (x / 2) + n,
        0,
      )
      ..lineTo(x - r, p)
      ..quadraticBezierTo(x, p, x, p + r)
      ..lineTo(x, y)
      ..lineTo(0, y)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
