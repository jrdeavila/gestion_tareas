import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class FollowersPage extends StatefulWidget {
  final FdSnapshot? guest;
  const FollowersPage({super.key, this.guest});

  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage>
    with TickerProviderStateMixin {
  late TabController _ctrl;
  var tabs = ['Seguidores', 'Siguiendo', 'Amigos'];
  @override
  void initState() {
    super.initState();
    _ctrl = TabController(length: tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: HomeAppBarAction(
          icon: MdiIcons.arrowLeft,
          selected: true,
          onTap: () {
            Get.back();
          },
        ),
        leadingWidth: 76.0,
        centerTitle: true,
        title: StreamBuilder(
            stream: Get.find<ProfileCtrl>()
                .getAccountStream(widget.guest?.reference.path),
            builder: (context, snapshot) {
              return Text(snapshot.data?.data()?['name'] ?? '******');
            }),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _ctrl,
            tabs: tabs.map((e) => Text(e)).toList(),
            indicatorPadding: EdgeInsets.zero,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
            indicator: const BoxDecoration(
              border: null,
              color: null,
            ),
            labelPadding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          ),
          Expanded(
            child: TabBarView(
              controller: _ctrl,
              children: [
                StreamBuilder(
                  stream: Get.find<ProfileCtrl>()
                      .getFollowers(widget.guest?.reference.path),
                  builder: (context, snapshot) {
                    return AccountList(
                      records: snapshot.data ?? [],
                    );
                  },
                ),
                StreamBuilder(
                  stream: Get.find<ProfileCtrl>()
                      .getFollowings(widget.guest?.reference.path),
                  builder: (context, snapshot) {
                    return AccountList(records: snapshot.data ?? []);
                  },
                ),
                StreamBuilder(
                  stream: Get.find<ProfileCtrl>()
                      .getFriends(widget.guest?.reference.path),
                  builder: (context, snapshot) {
                    return AccountList(records: snapshot.data ?? []);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AccountList extends StatelessWidget {
  const AccountList({
    super.key,
    required this.records,
  });

  final List<String> records;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(20.0),
        physics: const BouncingScrollPhysics(),
        itemBuilder: ((context, index) {
          return ListTile(
            leading: Skeleton(
              borderRadius: BorderRadius.circular(20.0),
              width: 40.0,
              height: 40.0,
            ),
            title: Skeleton(
              borderRadius: BorderRadius.circular(2.5),
              width: 80,
              height: 10,
            ),
          );
        }),
        itemCount: 10,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20.0),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        var related = records[index];
        return StreamBuilder(
            stream: Get.find<ProfileCtrl>().getAccountStream(related),
            builder: (context, snapshot) {
              return ListTile(
                onTap: () {
                  if (snapshot.hasData) {
                    Get.toNamed(
                      AppRoutes.guestProfile,
                      arguments: snapshot.data,
                    );
                  }
                },
                leading: ProfileImage(
                  image: snapshot.data?.data()?['image'],
                  name: snapshot.data?.data()?['name'],
                  active: snapshot.data?.data()?['active'] ?? false,
                  hasVisit: snapshot.data?.data()?['currentVisit'] != null,
                ),
                title: Text(snapshot.data?.data()?['name'] ?? "*****"),
              );
            });
      },
      itemCount: records.length,
    );
  }
}
