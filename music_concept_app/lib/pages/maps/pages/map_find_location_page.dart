import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:music_concept_app/lib.dart';

class ResumeMapLocation extends StatefulWidget {
  const ResumeMapLocation({
    super.key,
    this.position,
    this.onLocationChange,
    this.radius = 20.0,
    this.margin = 8.0,
  });

  final LatLng? position;
  final void Function(PlaceDetails)? onLocationChange;
  final double radius;
  final double margin;

  @override
  State<ResumeMapLocation> createState() => _ResumeMapLocationState();
}

class _ResumeMapLocationState extends State<ResumeMapLocation> {
  GoogleMapController? _ctrl;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.all(widget.margin),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius),
          child: SizedBox(
            height: 200,
            width: 200,
            child: GoogleMap(
              onMapCreated: (ctrl) {
                _ctrl = ctrl;
                ctrl.setMapStyle(AppDefaults.mapStyles);
                setState(() {});
              },
              onTap: (_) {
                Get.toNamed(AppRoutes.mapsFindLocation)?.then((value) {
                  if (value != null) {
                    _ctrl?.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          zoom: 15,
                          target: LatLng(
                            value.result!.geometry!.location!.lat!,
                            value.result!.geometry!.location!.lng!,
                          ),
                        ),
                      ),
                    );
                    widget.onLocationChange?.call(value);
                  }
                });
              },
              tiltGesturesEnabled: false,
              myLocationEnabled: false,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              zoomGesturesEnabled: false,
              rotateGesturesEnabled: false,
              scrollGesturesEnabled: false,
              initialCameraPosition: CameraPosition(
                zoom: 15,
                target: widget.position != null
                    ? widget.position!
                    : AppDefaults.defaultPositon,
              ),
              markers: {
                if (widget.position != null)
                  Marker(
                    markerId: const MarkerId('1'),
                    position: widget.position!,
                    infoWindow: const InfoWindow(
                      title: "Ubicacion GPS",
                    ),
                  ),
              },
            ),
          ),
        ),
      ),
    );
  }
}

class MapFindLocationPage extends StatefulWidget {
  const MapFindLocationPage({super.key});

  @override
  State<MapFindLocationPage> createState() => _MapFindLocationPageState();
}

class _MapFindLocationPageState extends State<MapFindLocationPage> {
  GoogleMapController? _controller;
  late LatLng? _point;
  PlaceDetails? _selectedPoint;

  @override
  void initState() {
    super.initState();
    _point = Get.find<LocationCtrl>().position != null
        ? LatLng(
            Get.find<LocationCtrl>().position!.latitude,
            Get.find<LocationCtrl>().position!.longitude,
          )
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<LocationCtrl>();
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
                onLongPress: (latLng) {
                  _point = latLng;
                  _animateTo(lat: latLng.latitude, lng: latLng.longitude);
                  setState(() {});
                },
                onMapCreated: (controller) {
                  _controller = controller;
                  controller.setMapStyle(AppDefaults.mapStyles);
                  setState(() {});
                },
                compassEnabled: false,
                zoomControlsEnabled: false,
                initialCameraPosition: const CameraPosition(
                  zoom: 10,
                  target: LatLng(
                    10.4634,
                    -73.2532,
                  ),
                ),
                polygons: {
                  // Radio circular de 500 metros de la posicion seleccionada
                  if (_point != null)
                    GeolocationUtils.getRadiusAbovePoint(
                      center: _point!,
                      radius: 500, // Metros
                    )
                },
                markers: {
                  if (ctrl.position != null)
                    Marker(
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueOrange,
                        ),
                        markerId: const MarkerId('1'),
                        position: LatLng(
                          ctrl.position!.latitude,
                          ctrl.position!.longitude,
                        ),
                        infoWindow: const InfoWindow(
                          title: "Ubicacion GPS",
                        )),
                  if (_selectedPoint != null)
                    Marker(
                      infoWindow: const InfoWindow(title: "Punto seleccionado"),
                      markerId: const MarkerId('2'),
                      position: LatLng(
                        _selectedPoint!.result!.geometry!.location!.lat!,
                        _selectedPoint!.result!.geometry!.location!.lng!,
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueBlue,
                      ),
                    ),
                  if (_point != null)
                    Marker(
                      infoWindow: const InfoWindow(
                        title: "Marca de busqueda",
                      ),
                      zIndex: 2,
                      markerId: const MarkerId('3'),
                      position: _point!,
                    ),
                }),
          ),
          // Buscar direccion
          Positioned(
            top: kToolbarHeight + 20.0,
            left: 20.0,
            right: 20.0,
            child: SearchPlacesTextField(
              onTapItem: (item) {
                var latLng = LatLng(
                  double.parse(item.lat!),
                  double.parse(item.lng!),
                );
                _animateTo(
                  lat: latLng.latitude,
                  lng: latLng.longitude,
                );

                _point = latLng;
                setState(() {});
              },
            ),
          ),
          // Informacion de la ubicacion actual
          _positionDetails(),
          AnimatedPositioned(
            bottom: 16.0 + (_point != null ? 200 : 0),
            right: 16.0 + (_selectedPoint != null ? 65.0 : 0),
            duration: 1.seconds,
            child: FloatingActionButton(
              heroTag: "select_location",
              child: const Icon(MdiIcons.mapMarkerCheck),
              onPressed: () {
                if (_selectedPoint != null) {
                  Get.back(result: _selectedPoint);
                }
              },
            ),
          ),
          AnimatedPositioned(
            bottom: 16.0 + (_point != null ? 200 : 0),
            right: 16.0,
            duration: 1.seconds,
            child: FloatingActionButton(
              heroTag: "my_location",
              backgroundColor: Colors.grey[700],
              child: const Icon(MdiIcons.mapMarker),
              onPressed: () {
                _point = LatLng(
                  ctrl.position!.latitude,
                  ctrl.position!.longitude,
                );
                _animateTo(
                  lat: ctrl.position?.latitude,
                  lng: ctrl.position?.longitude,
                );
                setState(() {});
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _positionDetails() {
    return FutureBuilder(
        future: _point != null
            ? SearchPlacesServices.searchPlaceDetailsByLatLng(_point!)
            : null,
        builder: (context, snapshot) {
          return AnimatedPositioned(
            right: 0,
            bottom: _point != null ? 0 : -250,
            left: 0,
            height: 250,
            duration: 1.seconds,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    decoration: BoxDecoration(
                        color: Get.theme.colorScheme.onBackground,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            offset: const Offset(0, -10),
                            color: Colors.black.withOpacity(0.1),
                          ),
                        ]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Text(
                            "Lugares cercanos",
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Text(
                            "Si no puedes encontrar tu direccion, puedes utilizar los lugares alternativos que queden cerca de tu ubicacion.",
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: snapshot.connectionState ==
                                  ConnectionState.waiting
                              ? ListView(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  scrollDirection: Axis.horizontal,
                                  children: List.generate(
                                      3,
                                      (index) =>
                                          const PositionDetailsSkeleton()),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  physics: const BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: ((context, index) {
                                    var item = snapshot.data?[index];

                                    return PositionDetails(
                                      mainPoint: _point,
                                      selected: item?.result?.placeId ==
                                          _selectedPoint?.result?.placeId,
                                      onTap: () {
                                        _selectedPoint = item;
                                        setState(() {});
                                      },
                                      placeDetails: item,
                                    );
                                  }),
                                  itemCount: snapshot.data?.length ?? 0,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future<void>? _animateTo({
    double? lat,
    double? lng,
  }) {
    return _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          zoom: 15,
          target: LatLng(
            lat!,
            lng!,
          ),
        ),
      ),
    );
  }
}
