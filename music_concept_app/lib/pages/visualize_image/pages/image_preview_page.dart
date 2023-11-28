import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImagePreviewPage extends StatelessWidget {
  final String imageUrl;
  const ImagePreviewPage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.background,
      appBar: AppBar(),
      body: Center(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: double.infinity,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          child: Container(
        height: 60.0,
        color: Get.theme.colorScheme.background,
      )),
    );
  }
}
