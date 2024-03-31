import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class ShowHistory extends StatefulWidget {
  final UserCreator userCreator;
  const ShowHistory({super.key, required this.userCreator});

  @override
  State<ShowHistory> createState() => _ShowHistoryState();
}

class _ShowHistoryState extends State<ShowHistory> {
  final _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentIndex = _pageController.page!.toInt();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final histories =
          Get.find<HistoryCtrl>().histories[widget.userCreator] ?? [];
      return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (histories.isNotEmpty)
              _buildImages(
                histories: histories,
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 20.0,
                      offset: const Offset(0, 0),
                      spreadRadius: 20.0,
                    ),
                  ],
                ),
              ),
            ),
            if (histories.isNotEmpty)
              _buildButtons(
                histories: histories,
              ),
            if (histories.first.isMine)
              Positioned(
                top: 20.0 + kToolbarHeight,
                right: 20.0,
                child: HomeAppBarAction(
                  icon: Icons.more_vert,
                  onTap: () {
                    Get.find<HistoryCtrl>()
                        .showOptions(histories[_currentIndex]);
                  },
                ),
              ),
          ],
        ),
      );
    });
  }

  Positioned _buildButtons({
    required List<History> histories,
  }) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(
              height: 100,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  histories[_currentIndex].description,
                  key: ValueKey(histories[_currentIndex].id),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _handlePrevious,
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: CachingImage(
                        url: histories.first.userCreator!.imageUrl,
                        height: 40.0,
                        width: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      histories.first.isMine
                          ? "Tu"
                          : histories.first.userCreator!.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _handleNext,
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImages({required List<History> histories}) {
    return PageView.builder(
      physics: const NeverScrollableScrollPhysics(),
      controller: _pageController,
      itemBuilder: (context, index) {
        return CachingImage(
          fit: BoxFit.cover,
          url: histories[index].imageUrl!,
          height: double.infinity,
        );
      },
      itemCount: histories.length,
    );
  }

  void _handleNext() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handlePrevious() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
