import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class SearchPlacesTextField extends StatefulWidget {
  const SearchPlacesTextField({
    super.key,
    this.onTapItem,
  });

  final void Function(Prediction position)? onTapItem;

  @override
  State<SearchPlacesTextField> createState() => _SearchPlacesTextFieldState();
}

class _SearchPlacesTextFieldState extends State<SearchPlacesTextField> {
  final TextEditingController _searchCtrl = TextEditingController();
  final GlobalKey _searchFieldKey = GlobalKey();
  CancelToken _cancelToken = CancelToken();
  OverlayEntry? _overlayEntry;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          blurRadius: 10,
          color: Colors.black.withOpacity(0.1),
        ),
      ]),
      child: TextField(
        key: _searchFieldKey,
        controller: _searchCtrl,
        style: TextStyle(
          color: Get.theme.colorScheme.primary,
        ),
        onChanged: _searchPlaces,
        decoration: InputDecoration(
          filled: true,
          fillColor: Get.theme.colorScheme.onBackground,
          prefixIcon: Icon(
            MdiIcons.magnify,
            color: Get.theme.colorScheme.primary,
          ),
          suffixIcon: GestureDetector(
            onTap: () {
              _clearPlaces();
            },
            child: Icon(
              MdiIcons.close,
              color: Colors.grey[400],
            ),
          ),
          hintText: 'Buscar direccion',
          hintStyle: TextStyle(
            color: Colors.grey[400],
          ),
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  _showPredictions(List<Prediction> predictions) {
    final renderBox =
        _searchFieldKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(builder: (context) {
      var pY = offset.dy + size.height + 20.0;
      return Positioned(
        top: pY,
        child: SizedBox(
          height: MediaQuery.of(context).size.height - pY,
          width: MediaQuery.of(context).size.width,
          child: GestureDetector(
            onTap: () {
              _clearPlaces();
            },
            child: Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      left: offset.dx,
                      right: offset.dx,
                    ),
                    width: size.width,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Get.theme.colorScheme.onBackground,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.1),
                                offset: const Offset(0, 5)),
                          ]),
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children:
                            predictions.map((e) => _predictionItem(e)).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  ListTile _predictionItem(Prediction prediction) {
    return ListTile(
      onTap: () {
        _onTapItem(prediction);
      },
      minVerticalPadding: 10.0,
      leading: Icon(
        MdiIcons.mapMarker,
        color: Get.theme.colorScheme.primary,
      ),
      minLeadingWidth: 0,
      title: Text(
        "${prediction.description}",
        style: TextStyle(
          color: Colors.grey[300],
        ),
      ),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            prediction.structuredFormatting?.mainText ?? "",
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12.0,
            ),
          ),
          Text(
            prediction.structuredFormatting?.secondaryText ?? "",
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }

  void _clearPlaces() {
    _searchCtrl.clear();
    _cancelToken.cancel();
    _cancelToken = CancelToken();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _searchPlaces(String value) {
    Future.delayed(
      const Duration(milliseconds: 600),
      () {
        _cancelToken.cancel();
        _cancelToken = CancelToken();

        SearchPlacesServices.searchPlaces(
                value: value, cancelToken: _cancelToken)
            .then((response) {
          if (response.isNotEmpty) {
            _overlayEntry?.remove();
            _overlayEntry = null;
            _overlayEntry = _showPredictions(response);
            Overlay.of(context).insert(_overlayEntry!);
          }
        });
      },
    );
  }

  void _onTapItem(Prediction prediction) {
    _clearPlaces();
    SearchPlacesServices.searchPlaceDetails(prediction.placeId!)
        .then((response) {
      prediction.lat = response.result?.geometry?.location?.lat?.toString();
      prediction.lng = response.result?.geometry?.location?.lng?.toString();
      widget.onTapItem?.call(prediction);
    });
  }
}
