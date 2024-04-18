import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CachingImage extends StatefulWidget {
  final String url;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final Widget errorWidget;

  const CachingImage({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.fit,
    this.errorWidget = const Icon(Icons.error),
  });

  @override
  State<CachingImage> createState() => _CachingImageState();
}

class _CachingImageState extends State<CachingImage> {
  final _cache = CacheManager(Config(
    'customCacheKey',
    stalePeriod: const Duration(days: 7),
    maxNrOfCacheObjects: 20,
  ));
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.url,
      cacheManager: _cache,
      height: widget.height,
      width: widget.width,
      fit: widget.fit,
      errorWidget: (context, url, error) {
        return widget.errorWidget;
      },
      placeholder: (context, url) => const Center(
        child: Skeleton(
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}

class Skeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const Skeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
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
      builder: (context, child) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(
            Colors.grey[300],
            Colors.grey[500],
            _controller.value,
          ),
          borderRadius: widget.borderRadius,
        ),
      ),
    );
  }
}
