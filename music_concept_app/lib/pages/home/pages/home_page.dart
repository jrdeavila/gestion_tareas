import 'package:flutter/material.dart';
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
