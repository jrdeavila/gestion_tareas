import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:music_concept_app/lib.dart';

class EventDialogContent extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>>? event;
  const EventDialogContent({
    super.key,
    this.event,
  });

  @override
  State<EventDialogContent> createState() => _EventDialogContentState();
}

class _EventDialogContentState extends State<EventDialogContent> {
  GoogleMapController? _googleMapCtrl;
  @override
  void initState() {
    super.initState();
    Get.lazyPut(() => CreateEventCtrl(
          Get.find<FirebaseCtrl>().defaultApp,
        ));
  }

  @override
  void dispose() {
    Get.delete<CreateEventCtrl>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CreateEventCtrl>();
    if (widget.event != null) {
      ctrl.loadInfo(widget.event!.data()!);
    }

    return Obx(() {
      if (ctrl.point != null) {
        _googleMapCtrl?.animateCamera(
          CameraUpdate.newLatLng(ctrl.point!),
        );
      }
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: SizedBox(
          width: Get.width * 0.85,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Material(
              color: Get.theme.colorScheme.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _headDialog(),
                  ResumeSelectDate(
                    date: ctrl.startDate,
                    onChangeDate: ctrl.setStartDate,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 15.0),
                    child: Text(
                      "Programa tus eventos con almenos 7 dias de antelacion.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                  const Divider(
                    height: 2,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  TextFormField(
                    initialValue: widget.event?['content'],
                    minLines: 1,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 22.0,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Nombre de tu evento',
                      hintStyle: TextStyle(),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 15.0),
                    ),
                    onChanged: ctrl.setContent,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  SizedBox(
                    height: 150,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: GestureDetector(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: GoogleMap(
                                onTap: (_) {
                                  Get.toNamed(AppRoutes.mapsFindLocation)
                                      ?.then((value) {
                                    if (value is PlaceDetails? &&
                                        value != null) {
                                      _googleMapCtrl?.animateCamera(
                                        CameraUpdate.newLatLng(
                                          LatLng(
                                            value.result!.geometry!.location!
                                                .lat!,
                                            value.result!.geometry!.location!
                                                .lng!,
                                          ),
                                        ),
                                      );
                                    }
                                  });
                                },
                                onMapCreated: (ctrl) {
                                  _googleMapCtrl = ctrl;
                                },
                                tiltGesturesEnabled: false,
                                myLocationEnabled: false,
                                mapToolbarEnabled: false,
                                zoomControlsEnabled: false,
                                zoomGesturesEnabled: false,
                                rotateGesturesEnabled: false,
                                scrollGesturesEnabled: false,
                                initialCameraPosition: const CameraPosition(
                                  zoom: 13,
                                  target: LatLng(
                                    10.4634,
                                    -73.2532,
                                  ),
                                ),
                                markers: {
                                  if (ctrl.point != null)
                                    Marker(
                                      markerId: const MarkerId("1"),
                                      position: ctrl.point!,
                                    ),
                                },
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: HomeAppBarAction(
                            icon: MdiIcons.close,
                            onTap: () {
                              ctrl.setPoint(null);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RoundedButton(
                        padding: EdgeInsets.zero,
                        onTap: ctrl.isUploading
                            ? null
                            : () => ctrl.submit(widget.event?.id),
                        radius: 20.0,
                        label: ctrl.isUploading ? null : 'Publicar',
                        child: ctrl.isUploading
                            ? Center(
                                child: LoadingIndicator(
                                  size: 25.0,
                                  count: 4,
                                  color: Get.theme.colorScheme.onPrimary,
                                ),
                              )
                            : null),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Padding _headDialog() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Crear Evento',
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              HomeAppBarAction(
                selected: true,
                icon: MdiIcons.close,
                onTap: () {
                  Get.back();
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}

class ResumeSelectDate extends StatelessWidget {
  const ResumeSelectDate({
    super.key,
    this.onChangeDate,
    this.date,
    this.readOnly = false,
    this.children = const [],
  });

  final ValueChanged<DateTime?>? onChangeDate;
  final DateTime? date;
  final bool readOnly;
  final List<Widget> children;

  void _pickDate(context) async {
    var now = DateTime.now();
    var themePicker = ThemeData.dark().copyWith(
      colorScheme: ColorScheme.dark(
        primary: Get.theme.colorScheme.primary,
        background: Get.theme.colorScheme.background,
        onBackground: Get.theme.colorScheme.onBackground,
      ),
    );
    var date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(
        7.days,
      ),
      builder: (context, child) {
        return Theme(
          data: themePicker,
          child: child!,
        );
      },
    );
    if (date == null) return;
    var time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      hourLabelText: "Hora",
      minuteLabelText: "Minutos",
      builder: (context, child) {
        return Theme(
          data: themePicker,
          child: child!,
        );
      },
    );
    if (time == null) return;
    var dateWithTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    onChangeDate?.call(dateWithTime);
  }

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    var isNotExpired = date != null && date!.isAfter(now.toLocal());

    return GestureDetector(
      onTap: !readOnly ? () => _pickDate(context) : null,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildCalendarDay(
                  isNotExpired,
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: _buildContent(
                    isNotExpired,
                  ),
                )
              ],
            ),
            if (!isNotExpired) ...[
              const SizedBox(height: 10.0),
              const Text(
                "Las fechas del evento ya expiraron",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Column _buildContent([bool isNotExpired = true]) {
    var now = DateTime.now();
    var color = isNotExpired ? Get.theme.colorScheme.primary : Colors.grey;
    String formattedDate =
        DateFormat("EEEEE, d 'de' MMMM 'del' y, hh:mm a", 'es')
            .format(date ?? now)
            .capitalize!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...(children),
        Text(
          formattedDate,
          style: TextStyle(
            fontSize: 14.0,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Center _buildCalendarDay([bool isNotExpired = true]) {
    var now = DateTime.now();
    var color = isNotExpired
        ? Get.theme.colorScheme.primary
        : Get.theme.colorScheme.error;
    return Center(
      child: Container(
        width: 80.0,
        height: 80.0,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: color,
          ),
          borderRadius: BorderRadius.circular(10.0),
          color: Get.theme.colorScheme.onBackground,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8.0),
                  ),
                ),
                child: Center(
                  child: Text(
                    DateFormat.MMM("es").format(date ?? now).capitalize!,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Center(
                child: Text(
                  "${date?.day ?? now.day}",
                  style: const TextStyle(
                    fontSize: 35.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
