import 'dart:developer' as developer;
import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:events/core/providers/local_image_provider.dart';
import 'package:events/core/providers/local_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octo_image/octo_image.dart';

class CachedImage extends StatefulWidget {
  const CachedImage({
    required this.url,
    this.fit,
    this.imageBuilder,
    super.key,
  });
  final String url;
  final BoxFit? fit;
  final OctoImageBuilder? imageBuilder;

  @override
  State<CachedImage> createState() => CachedImageState();
}

class CachedImageState extends State<CachedImage> {
  ValueNotifier<ImageProvider?> imageReady = ValueNotifier(null);

  late LocalImageProvider fs;
  bool get _isRemote => widget.url.startsWith('http://') || widget.url.startsWith('https://');

  Future<ImageProvider> getImageProvider() async {
    if (widget.url.contains(LocalPathProvider.cacheFolder)) {
      return FileImage(
        File(widget.url),
      );
    }
    if (!_isRemote) {
      final file = await fs.getImageFile(widget.url);

      if (await file.exists()) {
        // Check if file is empty to prevent "LocalFile is empty" crash
        final fileSize = await file.length();
        if (fileSize == 0) {
          throw Exception('Image file is empty: ${widget.url}');
        }

        return FileImage(
          file,
        );
      }
    }

    return CachedNetworkImageProvider(
      widget.url,
      errorListener: (error) {
        developer.log('CachedNetworkImageProvider: failed to load image ${widget.url}, error: $error}');
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fs = context.read<LocalImageProvider>();
    unawaited(loadImageData());
  }

  Future<void> loadImageData() async {
    try {
      // We have to sync completion rate with image provider otherwise incorrect grayscale effect will be applied
      final privider = await getImageProvider();

      imageReady.value = privider;
    } catch (e) {
      // Log the error and set imageReady to null to trigger error builder
      developer.log('Failed to load image data for ${widget.url}: $e');
      imageReady.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: imageReady,
      builder: (context, imageReadyData, child) {
        if (imageReadyData == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final imageProvider = imageReadyData;

        return OctoImage(
          image: imageProvider,
          colorBlendMode: BlendMode.clear,
          fit: widget.fit,
          filterQuality: FilterQuality.none,
          imageBuilder: (context, child) {
            return widget.imageBuilder?.call(context, child) ?? child;
          },
          errorBuilder: onImageLoadError,
          gaplessPlayback: true,
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
        );
      },
    );
  }

  Widget onImageLoadError(BuildContext context, Object error, StackTrace? stackTrace) {
    developer.log('Image load error for ${widget.url}: $error');

    return const Icon(Icons.broken_image_rounded, size: 35, color: Color(0xff939393));
  }
}
