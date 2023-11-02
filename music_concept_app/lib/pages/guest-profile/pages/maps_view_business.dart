import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:music_concept_app/lib.dart';

class MapsViewBusinessPage extends StatefulWidget {
  const MapsViewBusinessPage({super.key});

  @override
  State<MapsViewBusinessPage> createState() => _MapsViewBusinessPageState();
}

class _MapsViewBusinessPageState extends State<MapsViewBusinessPage> {
  GoogleMapController? _googleCtrl;
  FdSnapshot? _selectedBusiness;
  final _scrollCtrl = ScrollController();
  final ctrl = Get.find<BusinessNearlyCtrl>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: _buildMaps(),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 220.0,
              child: _buildScrollableBusiness(),
            ),
            Positioned(
              left: 16.0,
              top: kToolbarHeight + 16.0,
              child: HomeAppBarAction(
                icon: MdiIcons.arrowLeft,
                selected: true,
                light: true,
                onTap: Get.back,
              ),
            ),
            AnimatedPositioned(
              right: _selectedBusiness == null ? -150.0 : 16.0,
              bottom: 236,
              duration: 500.milliseconds,
              child: FloatingActionButton.extended(
                onPressed: () {
                  if (_selectedBusiness != null) {
                    var point =
                        (_selectedBusiness!["location"] as GeoPoint).toLatLng();

                    GeolocationUtils.navigateToMaps(
                      point.latitude,
                      point.longitude,
                    );
                  }
                },
                label: const Text("Navegar"),
                icon: const Icon(
                  MdiIcons.navigation,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  DecoratedBox _buildScrollableBusiness() {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
        color: Get.theme.colorScheme.background,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Establecimientos cercanos",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  var point = (ctrl.businesses[index]["location"] as GeoPoint)
                      .toLatLng();
                  return BusinessItemInfo(
                      key: ValueKey(ctrl.businesses[index].id),
                      business: ctrl.businesses[index],
                      selected:
                          _selectedBusiness?.id == ctrl.businesses[index].id,
                      onTap: () {
                        _googleCtrl?.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: point,
                              zoom: 17.0,
                            ),
                          ),
                        );
                        _toggleItem(ctrl.businesses[index]);
                      });
                },
                itemCount: ctrl.businesses.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  GoogleMap _buildMaps() {
    final firstBsnPoint =
        (ctrl.businesses.first["location"] as GeoPoint).toLatLng();

    var locationCtrl = Get.find<LocationCtrl>();
    var point = locationCtrl.position?.toLatLng();
    return GoogleMap(
      compassEnabled: false,
      trafficEnabled: false,
      liteModeEnabled: false,
      buildingsEnabled: false,
      myLocationEnabled: false,
      zoomControlsEnabled: false,
      rotateGesturesEnabled: false,
      mapToolbarEnabled: false,
      initialCameraPosition: CameraPosition(
        target: firstBsnPoint,
        zoom: 15.0,
      ),
      onMapCreated: (ctrl) {
        ctrl.setMapStyle(AppDefaults.mapStyles);
        _googleCtrl = ctrl;
      },
      polygons: {
        ...ctrl.businesses.map(
          (e) => GeolocationUtils.getRadiusAbovePoint(
            id: e.id,
            color: Colors.purple[400],
            center: (e["location"] as GeoPoint).toLatLng(),
            radius: ctrl.businessLimit,
          ),
        ),
        if (point != null)
          GeolocationUtils.getRadiusAbovePoint(
            center: point,
            radius: ctrl.userRadius,
          ),
      },
      markers: {
        ...ctrl.businesses.map(
          (e) => Marker(
            markerId: MarkerId(e.id),
            position: (e["location"] as GeoPoint).toLatLng(),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueViolet,
            ),
            onTap: () {
              _toggleItem(e);
            },
          ),
        ),
        if (locationCtrl.position != null)
          Marker(
            markerId: const MarkerId("myLocation"),
            position: LatLng(
              locationCtrl.position!.latitude,
              locationCtrl.position!.longitude,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
          ),
      },
    );
  }

  void _toggleItem(FdSnapshot e) {
    if (_selectedBusiness?.id != e.id) {
      _selectedBusiness = e;
    } else {
      _selectedBusiness = null;
    }
    setState(() {});
  }
}

class BusinessItemInfo extends StatelessWidget {
  final FdSnapshot business;
  final VoidCallback? onTap;
  final bool selected;
  const BusinessItemInfo({
    super.key,
    required this.business,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final point = (business["location"] as GeoPoint).toLatLng();
    final ctrl = Get.find<LocationCtrl>();
    return Obx(() => GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: 500.milliseconds,
            width: 250.0,
            padding: const EdgeInsets.all(20.0),
            margin: const EdgeInsets.only(right: 20.0),
            decoration: BoxDecoration(
              border: selected
                  ? Border.all(color: Get.theme.colorScheme.primary)
                  : null,
              borderRadius: BorderRadius.circular(20.0),
              color: selected
                  ? Get.theme.colorScheme.primary.withOpacity(0.2)
                  : Get.theme.colorScheme.onBackground,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      business["name"] as String,
                      style: const TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      " - ",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      business["category"],
                      style: TextStyle(
                        color: Get.theme.colorScheme.primary,
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5.0),
                Text(
                  business["address"] as String,
                  style: TextStyle(
                    color: Get.theme.colorScheme.onPrimary.withOpacity(0.5),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                if (ctrl.position != null)
                  Text(
                    GeolocationUtils.distanceBetweenString(
                      point.latitude,
                      point.longitude,
                      ctrl.position!.latitude,
                      ctrl.position!.longitude,
                    ),
                  )
              ],
            ),
          ),
        ));
  }
}
