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
              HomeAppBarAction(
                icon: MdiIcons.account,
                selected: ctrl.currentPage == 2,
                onTap: () {
                  ctrl.goToProfile();
                },
              ),
              const SizedBox(width: 16.0),
            ]),
          ),
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
