import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:music_concept_app/lib.dart';

class MapsViewLocationPage extends StatefulWidget {
  final FdSnapshot guest;
  const MapsViewLocationPage({
    super.key,
    required this.guest,
  });

  @override
  State<MapsViewLocationPage> createState() => _MapsViewLocationPageState();
}

class _MapsViewLocationPageState extends State<MapsViewLocationPage> {
  late FdSnapshot _guestSelected;
  GoogleMapController? googleMapCtrl;
  var ctrl = Get.find<LocationCtrl>();

  @override
  void initState() {
    super.initState();
    _guestSelected = widget.guest;
  }

  @override
  Widget build(BuildContext context) {
    var data = _guestSelected.data();
    LatLng point = LatLng(
      (data?["location"] as GeoPoint).latitude,
      (data?["location"] as GeoPoint).longitude,
    );
    return Obx(() {
      return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: GoogleMap(
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  myLocationEnabled: false,
                  compassEnabled: false,
                  trafficEnabled: false,
                  mapToolbarEnabled: false,
                  onMapCreated: (ctrl) {
                    ctrl.setMapStyle(AppDefaults.mapStyles);
                    googleMapCtrl = ctrl;
                  },
                  initialCameraPosition: CameraPosition(
                    target: point,
                    zoom: 17.0,
                  ),
                  polygons: {
                    GeolocationUtils.getRadiusAbovePoint(
                      center: point,
                      radius: 40.0,
                    ),
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId("guest"),
                      position: point,
                      infoWindow: InfoWindow(
                        title: data!["name"],
                      ),
                    ),
                    if (ctrl.position != null)
                      Marker(
                        markerId: const MarkerId("me"),
                        position: ctrl.position!.toLatLng(),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueBlue,
                        ),
                        infoWindow: const InfoWindow(
                          title: "Tu ubicacion",
                        ),
                      ),
                  },
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                    padding: const EdgeInsets.only(
                      left: 20.0,
                      right: 20.0,
                      top: 20.0 + kToolbarHeight,
                      bottom: 20.0,
                    ),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.background,
                      boxShadow: [
                        BoxShadow(
                          color: Get.theme.colorScheme.onBackground
                              .withOpacity(.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!ctrl.hasPermissions) ...[
                          _buildRequestPermissions(
                            backEnabled: !ctrl.hasPermissions,
                          ),
                          const Divider(),
                        ],
                        _buildGuestInfo(
                          backEnabled: ctrl.hasPermissions,
                        ),
                      ],
                    )),
              )
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (ctrl.position != null) {
                googleMapCtrl?.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: ctrl.position!.toLatLng(),
                      zoom: 17.0,
                    ),
                  ),
                );
              }
            },
            child: const Icon(
              Icons.my_location,
            ),
          ));
    });
  }

  Row _buildGuestInfo({
    bool backEnabled = true,
  }) {
    final data = _guestSelected.data();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (backEnabled)
          HomeAppBarAction(
            icon: MdiIcons.arrowLeft,
            selected: true,
            onTap: () {
              Get.back();
            },
          ),
        const SizedBox(
          width: 20.0,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    data?["name"] ?? "....",
                    style: const TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    " - ",
                    style: TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "(${data?["category"] ?? "...."})",
                    style: TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                      color: Get.theme.colorScheme.primary,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              Text(
                data?["address"] ?? "....",
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: RoundedButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            MdiIcons.phone,
                            color: Get.theme.colorScheme.onPrimary,
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Text(
                            "Llamar",
                            style: TextStyle(
                              color: Get.theme.colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Row _buildRequestPermissions({
    bool backEnabled = true,
  }) {
    final ctrl = Get.find<LocationCtrl>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (backEnabled)
          HomeAppBarAction(
            icon: MdiIcons.arrowLeft,
            selected: true,
            onTap: () {
              Get.back();
            },
          ),
        const SizedBox(
          width: 10.0,
        ),
        // if (!ctrl.hasPermissions)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Permisos de ubicacion denegados",
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 5.0,
              ),
              const Text(
                "Para poder ver tu ubicacion, debes activar la ubicacion en tu dispositivo.",
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: RoundedButton(
                      onTap: () {
                        ctrl.requestPermissions();
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      isBordered: true,
                      label: "Activar ubicacion",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
