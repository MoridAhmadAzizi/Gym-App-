import 'package:file/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image/image.dart';
import 'package:path/path.dart';

class RemoteImageProvider {
  RemoteImageProvider({
    required this.cacheManager,
  });

  final CacheManager cacheManager;

  Future<Image> getImage(String imageUrl) async {
    final manager = cacheManager;

    final fileInfo = await manager.getSingleFile(imageUrl);

    // Check if file exists before attempting to read (handles race condition where OS deleted file)
    if (!await fileInfo.exists()) {
      // Remove stale cache entry and force re-download
      await manager.removeFile(imageUrl);
      final refetchedFile = await manager.getSingleFile(imageUrl);

      if (!await refetchedFile.exists()) {
        throw PathException('Failed to download file after cache miss: $imageUrl');
      }

      final imageBytes = await refetchedFile.readAsBytes();
      final decodedImage = decodeImage(imageBytes);
      if (decodedImage != null) {
        return decodedImage;
      }
      throw PathException('Failed to decode re-downloaded image: $imageUrl');
    }

    final imageBytes = await fileInfo.readAsBytes();
    final decodedImage = decodeImage(imageBytes);
    if (decodedImage != null) {
      return decodedImage;
    }
    throw PathException('Failed to decode cached image: $imageUrl');
  }

  Future<File> getAttachment(String fileUrl) async {
    final manager = cacheManager;

    final fileInfo = await manager.getSingleFile(fileUrl);

    // Check if file exists before attempting to read (handles race condition where OS deleted file)
    if (!await fileInfo.exists()) {
      // Remove stale cache entry and force re-download
      await manager.removeFile(fileUrl);
      final refetchedFile = await manager.getSingleFile(fileUrl);

      if (!await refetchedFile.exists()) {
        throw PathException('Failed to download file after cache miss: $fileUrl');
      }

      return refetchedFile;
    }

    return fileInfo;
  }
}
