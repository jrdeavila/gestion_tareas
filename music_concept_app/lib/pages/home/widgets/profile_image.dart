import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class ProfileImage extends StatelessWidget {
  const ProfileImage({
    super.key,
    required this.image,
    required this.name,
    this.fontSize = 20.0,
    this.avatarSize = 40.0,
    this.active = false,
    this.hasVisit = false,
    this.isBusiness = false,
    this.isClickable = true,
  });

  final String? image;
  final String? name;
  final double fontSize;
  final double avatarSize;
  final bool active, hasVisit, isBusiness;
  final bool isClickable;

  @override
  Widget build(BuildContext context) {
    final hasImage = image != null;
    final percent = isBusiness ? 4 : 2;
    var avatarWidth = avatarSize * (isBusiness ? 2.0 : 1.0);
    return GestureDetector(
      onTap: isClickable
          ? () {
              if (hasImage) {
                Get.to(() => ImagePreviewPage(imageUrl: image!));
              }
            }
          : null,
      child: SizedBox(
        height: avatarSize,
        width: avatarWidth,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipPath(
                clipper: StatusClipper(
                  active: active,
                  radius: 0.1538 * avatarSize,
                  dx: 0.2307 * avatarSize / 2,
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Builder(builder: (context) {
                        if (hasImage) {
                          return Container(
                            height: avatarSize,
                            width: avatarSize,
                            decoration: BoxDecoration(
                              color: Get.theme.colorScheme.onPrimary,
                              borderRadius:
                                  BorderRadius.circular(avatarSize / percent),
                            ),
                            child: Center(
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(avatarSize / percent),
                                child: CachingImage(
                                  url: image!,
                                  fit: BoxFit.cover,
                                  height: avatarSize - 3,
                                  width: double.infinity - 3,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Container(
                            height: avatarSize,
                            width: avatarWidth,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius:
                                  BorderRadius.circular(avatarSize / percent),
                              border: Border.all(
                                color: Get.theme.colorScheme.onPrimary,
                                width: 1.0,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                name?[0].toUpperCase() ?? '',
                                style: TextStyle(
                                  fontSize: fontSize,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        }
                      }),
                    ),
                    if (hasVisit) ...[
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: avatarWidth,
                          height: avatarSize,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius:
                                BorderRadius.circular(avatarSize / percent),
                            border: Border.all(
                              color: Get.theme.colorScheme.onPrimary,
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: avatarWidth,
                          height: avatarSize,
                          child: MusicVisualizerAnimation(
                            lines: isBusiness ? 12 : 6,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (active)
              Positioned(
                height: 0.2307 * avatarSize,
                width: 0.2307 * avatarSize,
                bottom: 0.0,
                right: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    border: Border.all(
                      color: Get.theme.colorScheme.onPrimary,
                      width: 1.0,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MusicVisualizerAnimation extends StatelessWidget {
  final int lines;
  const MusicVisualizerAnimation({
    super.key,
    this.lines = 6,
  });

  @override
  Widget build(BuildContext context) {
    List<int> percents = [900, 700, 600, 800, 500];
    return LayoutBuilder(builder: (context, constraints) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          lines,
          (index) {
            return MusicVisualizerBar(
              color: Get.theme.colorScheme.onPrimary,
              duration: percents[index % 5],
              maxHeight: constraints.maxHeight * 0.4,
              width: constraints.maxWidth / (18 * lines / 6),
            );
          },
        ),
      );
    });
  }
}

class MusicVisualizerBar extends StatefulWidget {
  const MusicVisualizerBar({
    super.key,
    required this.color,
    required this.duration,
    this.maxHeight = 100.0,
    this.width = 8.0,
  });

  final Color color;
  final int duration;
  final double maxHeight, width;

  @override
  State<MusicVisualizerBar> createState() => _MusicVisualizerBarState();
}

class _MusicVisualizerBarState extends State<MusicVisualizerBar>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController animationCtrl;

  @override
  void initState() {
    super.initState();
    animationCtrl = AnimationController(
      vsync: this,
      duration: widget.duration.milliseconds,
    );
    final curvedAnimation = CurvedAnimation(
      parent: animationCtrl,
      curve: Curves.easeInOutSine,
    );
    animation =
        Tween<double>(begin: 0, end: widget.maxHeight).animate(curvedAnimation)
          ..addListener(() {
            setState(() {});
          });

    animationCtrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    animationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(5.0),
      ),
      height: animation.value,
    );
  }
}

class StatusClipper extends CustomClipper<Path> {
  final bool active;
  final double radius, dx;
  const StatusClipper({
    this.active = false,
    this.radius = 20.0,
    this.dx = 15.0,
  });
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..lineTo(0, size.height)
      ..close()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width - dx, size.height - dx),
          radius: active ? radius : 0.0,
        ),
      );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
