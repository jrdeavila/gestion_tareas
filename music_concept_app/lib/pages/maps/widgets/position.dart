import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:music_concept_app/lib.dart';

class PositionDetails extends StatelessWidget {
  final LatLng? mainPoint;
  final PlaceDetails? placeDetails;
  final VoidCallback? onTap;
  final bool selected;
  const PositionDetails({
    super.key,
    this.placeDetails,
    this.onTap,
    this.selected = false,
    this.mainPoint,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        width: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selected
              ? Get.theme.colorScheme.primary.withOpacity(0.2)
              : Colors.grey[800],
        ),
        margin: const EdgeInsets.only(right: 20),
        child: Row(
          children: [
            Icon(
              MdiIcons.mapMarker,
              color: Get.theme.colorScheme.primary,
              size: 40.0,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    placeDetails?.result?.name ?? '',
                    style: TextStyle(
                      color: Get.theme.colorScheme.onPrimary,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.start,
                  ),
                  Text(
                    placeDetails?.result?.formattedAddress ?? '',
                    style: TextStyle(
                      color: Get.theme.colorScheme.onPrimary,
                      overflow: TextOverflow.ellipsis,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (mainPoint != null)
                    Text(
                      GeolocationUtils.distanceBetweenString(
                        mainPoint!.latitude,
                        mainPoint!.longitude,
                        placeDetails!.result!.geometry!.location!.lat!,
                        placeDetails!.result!.geometry!.location!.lng!,
                      ),
                      style: TextStyle(
                        color: Get.theme.colorScheme.onPrimary,
                      ),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PositionDetailsSkeleton extends StatefulWidget {
  const PositionDetailsSkeleton({super.key});

  @override
  State<PositionDetailsSkeleton> createState() =>
      _PositionDetailsSkeletonState();
}

class _PositionDetailsSkeletonState extends State<PositionDetailsSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: 2.seconds)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(right: 20),
          width: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey[800],
          ),
          child: Row(
            children: [
              SkeletonBox(
                radius: 20.0,
                width: 40,
                height: 40,
                value: _controller.value,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(
                      radius: 5.0,
                      width: 140,
                      height: 20,
                      value: _controller.value,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SkeletonBox(
                      radius: 2.0,
                      width: 200,
                      height: 10,
                      value: _controller.value,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SkeletonBox(
                      radius: 2.0,
                      width: 100,
                      height: 10,
                      value: _controller.value,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SkeletonBox(
                      radius: 2.0,
                      width: 150,
                      height: 10,
                      value: _controller.value,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
