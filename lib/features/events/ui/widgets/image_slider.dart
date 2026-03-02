import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:events/core/widgets/cached_image.dart';
import 'package:flutter/material.dart';

class _ImageItem extends StatelessWidget {
  const _ImageItem({
    super.key,
    required this.imagePath,
  });

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return CachedImage(url: imagePath);
  }
}

class ImageSlider extends StatefulWidget {
  const ImageSlider(this.images, {super.key});
  final List<String> images;

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  int _currentIndex = 0;
  @override
  void didUpdateWidget(covariant ImageSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(child: Icon(Icons.image, color: Colors.red, size: 60)),
      );
    }

    return Stack(
      children: [
        CarouselSlider(
          disableGesture: !(widget.images.length > 1),
          items: widget.images
              .map((url) => ColoredBox(
                    color: Colors.red,
                    child: _ImageItem(
                      key: ValueKey(url),
                      imagePath: url,
                    ),
                  ))
              .toList(),
          options: CarouselOptions(
            aspectRatio: 16 / 9,
            autoPlay: widget.images.length > 1,
            autoPlayInterval: const Duration(seconds: 5),
            viewportFraction: 1,
            onPageChanged: (index, reason) => setState(() {
              _currentIndex = index;
            }),
          ),
        ),
        const SizedBox(height: 12),
        Positioned(bottom: 10, left: 0, right: 0, child: Center(child: _buildPageIndicator(widget.images.length))),
      ],
    );
  }

  Widget _buildPageIndicator(int length) {
    if (length <= 1) return const SizedBox();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.shadow.withAlpha(115), borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(length, (index) {
                final isActive = index == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isActive ? Theme.of(context).primaryColor : Colors.white,
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
