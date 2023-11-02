import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({
    super.key,
    this.guest,
  });

  final DocumentSnapshot<Map<String, dynamic>>? guest;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  int _currentTab = 1;
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postCtrl = Get.find<PostCtrl>();

    return Stack(
      fit: StackFit.expand,
      children: [
        BackgroundProfile(
          scrollCtrl: _scrollCtrl,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  Get.theme.colorScheme.background,
                  Get.theme.colorScheme.background.withOpacity(0),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: const [
                  0.6,
                  1.0,
                ]),
          ),
        ),
        StreamBuilder(
            stream: postCtrl.profilePosts(
              guestRef: widget.guest?.reference.path,
            ),
            builder: (context, snapshot) {
              return CustomScrollView(
                controller: _scrollCtrl,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    floating: true,
                    backgroundColor: Colors.transparent,
                    leadingWidth: 76,
                    toolbarHeight: kToolbarHeight + 50,
                    leading: HomeAppBarAction(
                      selected: true,
                      icon: MdiIcons.arrowLeft,
                      onTap: () {
                        if (widget.guest != null) {
                          Get.back();
                        } else {
                          Get.find<HomeCtrl>().goToReed();
                        }
                      },
                    ),
                    actions: [
                      const SizedBox(width: 10.0),
                      if (widget.guest == null)
                        HomeAppBarAction(
                          selected: true,
                          icon: MdiIcons.dotsVertical,
                          onTap: () {
                            Scaffold.of(context).openEndDrawer();
                          },
                        ),
                      const SizedBox(width: 16.0),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: _accountDetails(),
                  ),
                  SliverToBoxAdapter(
                    child: AccountFollowFollowers(
                      guest: widget.guest,
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20.0),
                  ),
                  SliverToBoxAdapter(
                    child: ProfileTabBar(
                      children: [
                        if (widget.guest == null)
                          ProfileTabBarItem(
                            label: 'Fondos',
                            icon: MdiIcons.wallpaper,
                            selected: _currentTab == 0,
                            onTap: () {
                              setState(() {
                                _currentTab = 0;
                              });
                            },
                          ),
                        ProfileTabBarItem(
                            label: 'Posts',
                            icon: MdiIcons.post,
                            selected: _currentTab == 1,
                            onTap: () {
                              setState(() {
                                _currentTab = 1;
                              });
                            }),
                        ProfileTabBarItem(
                            label: 'Visitas',
                            icon: MdiIcons.sitemap,
                            selected: _currentTab == 2,
                            onTap: () {
                              setState(() {
                                _currentTab = 2;
                              });
                            }),
                      ],
                    ),
                  ),
                  if (_currentTab == 0 && widget.guest == null)
                    const SliverFillRemaining(
                      child: WallpaperTabView(),
                    ),
                  if (_currentTab == 1 &&
                          snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.connectionState == ConnectionState.none)
                    const SliverToBoxAdapter(
                      child: LoadingPostSkeleton(),
                    ),
                  if (_currentTab == 1 &&
                      snapshot.connectionState == ConnectionState.active &&
                      snapshot.hasData &&
                      snapshot.data!.isNotEmpty)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Center(
                            child: PostItem(
                              isReed: widget.guest != null,
                              snapshot: snapshot.data![index],
                            ),
                          );
                        },
                        childCount: snapshot.data?.length ?? 0,
                      ),
                    ),
                  if (_currentTab == 2)
                    SliverToBoxAdapter(
                      child: StreamBuilder(
                          stream: Get.find<ProfileCtrl>()
                              .getAccountStream(widget.guest?.reference.path),
                          builder: (context, snapshot) {
                            var isBusiness =
                                snapshot.data?.data()?['type'] == 0;
                            return StreamBuilder(
                              stream: !isBusiness
                                  ? Get.find<ProfileCtrl>().getBusinessVisits(
                                      accountRef: widget.guest?.reference.path,
                                    )
                                  : Get.find<ProfileCtrl>().getVisitors(
                                      accountRef: widget.guest?.reference.path,
                                    ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return SizedBox(
                                    height: 180.0,
                                    child: ListView(
                                      physics: const BouncingScrollPhysics(),
                                      padding: const EdgeInsets.all(16.0),
                                      scrollDirection: Axis.horizontal,
                                      children: List.generate(
                                        5,
                                        (index) => const BusinessItemSkeleton(),
                                      ),
                                    ),
                                  );
                                }
                                if (snapshot.connectionState ==
                                        ConnectionState.done &&
                                    (snapshot.data?.isEmpty ?? false)) {
                                  return const SizedBox.shrink();
                                }
                                return SizedBox(
                                  height: 180,
                                  child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.all(16.0),
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      var item = snapshot.data![index];
                                      return BusinessItem(
                                        item: item,
                                        isBusiness: !isBusiness,
                                      );
                                    },
                                    itemCount: snapshot.data?.length ?? 0,
                                  ),
                                );
                              },
                            );
                          }),
                    ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100.0),
                  )
                ],
              );
            }),
      ],
    );
  }

  Widget _accountDetails() {
    String lastActiveString = "";
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: StreamBuilder(
              stream: Get.find<ProfileCtrl>().getAccountStream(
                widget.guest?.reference.path,
              ),
              builder: (context, snapshot) {
                var data = snapshot.data?.data();
                var hasAddress = data?['address'] != null;
                var hasActiveStatus = data?.containsKey('active') ?? false
                    ? data!['active']
                    : false;
                var hasLastActive = data?['lastActive'] != null;
                lastActiveString = hasLastActive
                    ? "Activo ${data?['active'] ?? false ? "ahora" : TimeUtils.timeagoFormat(data?["lastActive"].toDate())}"
                    : lastActiveString;
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ProfileImage(
                        isBusiness: data?['type'] == 0,
                        hasVisit: data?['currentVisit'] != null,
                        name: data?['name'],
                        image: data?['image'],
                        active: hasActiveStatus,
                        avatarSize: 130.0,
                        fontSize: 40.0,
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        data?['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (data?['currentVisit'] != null) ...[
                        const SizedBox(
                          height: 10.0,
                        ),
                        StreamBuilder(
                            stream: Get.find<ProfileCtrl>()
                                .getFollowingInCurrentVisit(accountRef: null),
                            builder: (context, snapshot) {
                              var length = snapshot.data?.length ?? 0;
                              var limit = 4;
                              var items = length >= limit ? limit : length;
                              var hasMore = length > limit;
                              var hasAlone = length == 0;
                              var offsetX = (160.0 - (25.0 * items)) / 2.25;
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Transform.translate(
                                    offset: Offset(offsetX, 0.0),
                                    child: SizedBox(
                                      width: 160.0,
                                      child: Row(
                                        children: [
                                          ...List.generate(
                                            items,
                                            (index) => StreamBuilder(
                                                stream: Get.find<ProfileCtrl>()
                                                    .getAccountStream(
                                                  snapshot.data![index],
                                                ),
                                                builder: (context, account) {
                                                  return Transform.translate(
                                                    offset: Offset(
                                                      index * -15.0,
                                                      0.0,
                                                    ),
                                                    child: ProfileImage(
                                                      image: account
                                                          .data?['image'],
                                                      name:
                                                          account.data?['name'],
                                                    ),
                                                  );
                                                }),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5.0),
                                  StreamBuilder(
                                      stream: Get.find<ProfileCtrl>()
                                          .getAccountStream(
                                              data!['currentVisit']),
                                      builder: (context, business) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              hasAlone
                                                  ? "esta en"
                                                  : "${hasMore ? "y otras personas mas" : ""} estan en ",
                                              style: TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                                color: Get.theme.colorScheme
                                                    .onPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 5.0),
                                            GestureDetector(
                                              onTap: () {
                                                Get.toNamed(
                                                    AppRoutes.guestProfile,
                                                    arguments: business.data);
                                              },
                                              child: ProfileImage(
                                                image: business.data?['image'],
                                                name: business.data?['name'],
                                              ),
                                            ),
                                            Text(
                                              business.data?['name']
                                                      ?.toUpperCase() ??
                                                  '',
                                              style: TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                                color: Get.theme.colorScheme
                                                    .onPrimary,
                                              ),
                                            ),
                                          ],
                                        );
                                      })
                                ],
                              );
                            }),
                        const SizedBox(
                          height: 10.0,
                        ),
                      ],
                      if (hasAddress)
                        Text(
                          data?['address'] ?? '',
                          style: TextStyle(
                              fontSize: 15.0,
                              color: Get.theme.colorScheme.primary),
                        ),
                      const SizedBox(height: 10.0),
                      Text(
                        lastActiveString,
                        style: TextStyle(
                          fontSize: 15.0,
                          color: data?["active"] ?? false
                              ? Get.theme.colorScheme.primary
                              : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          height: 60,
          width: 100,
          child: ImagePicker(
            canRemove: false,
            onImageSelected: (image) {
              if (image != null) {
                Get.find<ProfileCtrl>().changeAvatar(image);
              }
            },
            child: const Column(
              children: [
                Icon(
                  MdiIcons.camera,
                  color: Colors.grey,
                ),
                Text("Editar", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class BackgroundProfile extends StatefulWidget {
  const BackgroundProfile({
    super.key,
    required this.scrollCtrl,
  });

  final ScrollController scrollCtrl;

  @override
  State<BackgroundProfile> createState() => _BackgroundProfileState();
}

class _BackgroundProfileState extends State<BackgroundProfile> {
  double _backgroundOpacity = 1.0;

  @override
  void initState() {
    super.initState();

    widget.scrollCtrl.addListener(() {
      _backgroundOpacity = 1 - (widget.scrollCtrl.offset / 50).clamp(0, 1);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProfileCtrl>();

    return StreamBuilder(
        stream: ctrl.getAccountStream(),
        builder: (context, snapshot) {
          return Opacity(
            opacity: _backgroundOpacity,
            child: Container(
              margin: const EdgeInsets.only(
                top: kToolbarHeight - 20,
              ),
              decoration: BoxDecoration(
                image: ctrl.selectedWallpaper != null ||
                        snapshot.data?.data()?['background'] != null
                    ? DecorationImage(
                        image: AssetImage(
                            snapshot.data?.data()?['background'] ??
                                ctrl.selectedWallpaper),
                        fit: BoxFit.cover,
                      )
                    : null,
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
          );
        });
  }
}

class LoadingPostSkeleton extends StatelessWidget {
  const LoadingPostSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PostSkeleton(),
        PostSkeleton(),
        PostSkeleton(),
      ],
    );
  }
}
