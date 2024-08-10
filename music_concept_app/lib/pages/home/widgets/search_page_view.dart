import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:music_concept_app/lib.dart';

class SearchPageView extends StatelessWidget {
  const SearchPageView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchCtrl = TextEditingController();
    final ctrl = Get.find<SearchCtrl>();
    return Container(
      color: Get.theme.colorScheme.background,
      child: Column(
        children: [
          const SizedBox(
            height: kToolbarHeight + 16.0,
          ),
          const Text(
            "Buscar personas o establecimientos",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 30.0,
          ),
          Row(
            children: [
              const SizedBox(
                width: 16.0,
              ),
              Expanded(
                child: TextField(
                  controller: searchCtrl,
                  onChanged: ctrl.setSearchText,
                  decoration: InputDecoration(
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0.0,
                      horizontal: 16.0,
                    ),
                    hintText: "Buscar..",
                    fillColor: Get.theme.colorScheme.onBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: GestureDetector(
                      child: const Icon(MdiIcons.close),
                      onTap: () {
                        searchCtrl.clear();
                        ctrl.clearResults();
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 16.0,
              ),
              HomeAppBarAction(
                selected: true,
                icon: MdiIcons.arrowRight,
                onTap: () {
                  Get.find<HomeCtrl>().goToReed();
                },
              ),
              const SizedBox(
                width: 16.0,
              ),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          Obx(
            () => ProfileTabBar(
              children: [
                ProfileTabBarItem(
                  label: 'Explorar',
                  icon: MdiIcons.musicNote,
                  selected: !ctrl.isMapSearching,
                  onTap: () => ctrl.setMapSearching(false),
                ),
                ProfileTabBarItem(
                  label: 'TADA',
                  icon: MdiIcons.hatFedora,
                  selected: !ctrl.isMapSearching,
                  onTap: () => ctrl.goToTada(),
                ),
                ProfileTabBarItem(
                  label: 'Descubrir',
                  icon: MdiIcons.mapMarkerRadius,
                  selected: ctrl.isMapSearching,
                  onTap: () => ctrl.setMapSearching(true),
                ),
              ],
            ),
          ),
          const Row(
            children: [
              SizedBox(
                width: 16.0,
              ),
              Text(
                "Filtrar por categoría",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Obx(() => SizedBox(
                height: 70,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(
                    16.0,
                  ),
                  scrollDirection: Axis.horizontal,
                  children: [
                    TagFilter(
                      selected: ctrl.currentCategory == null,
                      label: "Todos",
                      onTap: () => ctrl.setSelectedCategory(null),
                    ),
                    TagFilter(
                      selected: ctrl.currentCategory == "Personas",
                      label: "Personas",
                      onTap: () => ctrl.setSelectedCategory("Personas"),
                    ),
                    TagFilter(
                      selected: ctrl.currentCategory == "Amigos Compartiendo",
                      label: "Amigos Compartiendo",
                      onTap: () =>
                          ctrl.setSelectedCategory("Amigos Compartiendo"),
                    ),
                    ...ctrl.categories.map((element) => TagFilter(
                          selected: ctrl.currentCategory == element,
                          label: element,
                          onTap: () => ctrl.setSelectedCategory(element),
                        ))
                  ],
                ),
              )),
          Row(
            children: [
              const SizedBox(
                width: 16.0,
              ),
              Obx(() => Text(
                    "Resultados (${ctrl.searchResult.length})",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  )),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          Expanded(
            child: Obx(() {
              if (ctrl.isMapSearching) {
                var locationCtrl = Get.find<LocationCtrl>();
                return GoogleMap(
                  zoomControlsEnabled: false,
                  tiltGesturesEnabled: false,
                  myLocationButtonEnabled: false,
                  indoorViewEnabled: false,
                  trafficEnabled: false,
                  liteModeEnabled: false,
                  mapToolbarEnabled: false,
                  initialCameraPosition: CameraPosition(
                    target:
                        locationCtrl.position?.toLatLng() ?? const LatLng(0, 0),
                    zoom: 12.0,
                  ),
                  onMapCreated: (controller) {
                    controller.setMapStyle(AppDefaults.mapStyles);
                  },
                  markers: {
                    if (locationCtrl.position != null)
                      Marker(
                        markerId: const MarkerId("current"),
                        position: locationCtrl.position!.toLatLng(),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueBlue,
                        ),
                        infoWindow: const InfoWindow(
                          title: "Mi ubicación",
                        ),
                      ),
                    ...ctrl.searchResult
                        .where((element) => element.data()?['location'] != null)
                        .map(
                          (element) => Marker(
                            markerId: MarkerId(element.id),
                            position:
                                (element["location"] as GeoPoint).toLatLng(),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueViolet,
                            ),
                            infoWindow: InfoWindow(
                              title: element.data()?['name'],
                              snippet: element.data()?['address'],
                              onTap: () {
                                Get.find<FanPageCtrl>()
                                    .goToGuestProfile(element);
                              },
                            ),
                          ),
                        ),
                  },
                );
              }

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final data = ctrl.searchResult[index].data();
                  final hasAddress = data!['address'] != null;
                  return ListTile(
                    onTap: () {
                      Get.find<FanPageCtrl>()
                          .goToGuestProfile(ctrl.searchResult[index]);
                    },
                    leading: ProfileImage(
                      image: data['image'],
                      name: data['name'],
                      active: data['active'] ?? false,
                      hasVisit: ctrl.currentCategory == "Amigos Compartiendo" &&
                          data['currentVisit'] != null,
                    ),
                    title: Text(data['name']),
                    subtitle: hasAddress ? Text(data['address']) : null,
                  );
                },
                itemCount: ctrl.searchResult.length,
              );
            }),
          ),
        ],
      ),
    );
  }
}

class TagFilter extends StatelessWidget {
  final bool selected;
  final String label;
  final VoidCallback onTap;
  const TagFilter({
    super.key,
    required this.selected,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        right: 16.0,
      ),
      child: GestureDetector(
        onTap: () {
          Get.find<ActivityCtrl>().resetTimer();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 16.0,
          ),
          decoration: BoxDecoration(
            color: selected
                ? Get.theme.colorScheme.primary
                : Get.theme.colorScheme.onBackground,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
