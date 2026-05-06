import 'dart:typed_data';

import 'package:events/core/providers/remote_image_provider.dart';
import 'package:file/file.dart';
import 'package:image/image.dart';

import 'local_path_provider.dart';

class LocalImageProvider {
  LocalImageProvider(
    this.fs,
    this.remoteImageProvider,
  ) : pathBuilder = LocalPathProvider(fs);

  LocalImageProvider.fileSystem(this.fs, this.remoteImageProvider) {
    pathBuilder = LocalPathProvider(fs);
  }
  final RemoteImageProvider remoteImageProvider;
  final FileSystem fs;
  late final LocalPathProvider pathBuilder;

  Future<File> getImageFile(String imagePath) async {
    return pathBuilder.getImageFromStorage(imagePath);
  }

  //Saves images on device, accepts fullpath to image or url, but takes only filename from it
  Future<String> saveImage(String imagePath) async {
    final image = await remoteImageProvider.getImage(imagePath);
    final encodedPng = encodePng(image);

    return _saveImage(encodedPng, imagePath: imagePath);
  }

  Future<String> _saveImage(Uint8List encodedPng, {String? imagePath, Future<File> Function()? fileGenerator}) async {
    assert(imagePath != null || fileGenerator != null, 'Either imagePath or fileGenerator must be provided');

    final imageFile = await (fileGenerator?.call() ?? pathBuilder.getImageFromStorage(imagePath!));

    // Ensure the destination directory exists, but do not create/overwrite the final file yet.
    await imageFile.parent.create(recursive: true);

    // Write to a temporary file in the same directory, then atomically rename to the final path.
    // This avoids readers seeing a partially-written file.
    final tempFile = fs.file('${imageFile.path}.tmp.${DateTime.now().microsecondsSinceEpoch}');
    await tempFile.writeAsBytes(encodedPng, flush: true);

    // // Attempt to rename with a short retry loop to handle transient sharing violations on Windows
    // // if the destination file is momentarily open by a reader.
    const maxAttempts = 5;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        await tempFile.rename(imageFile.path);
        break;
      } catch (_) {
        try {
          if (await imageFile.exists()) {
            await imageFile.delete();
          }
        } catch (_) {
          // Ignore; we'll backoff and retry.
        }

        if (attempt == maxAttempts) {
          rethrow;
        }

        // Exponential backoff: 50ms, 100ms, 150ms, ...
        await Future<void>.delayed(Duration(milliseconds: 50 * attempt));
      }
    }

    return imageFile.path;
  }

  Future<String> saveAttachment(String attachmentPath) async {
    final attachmentToSave = await remoteImageProvider.getAttachment(attachmentPath);

    return _saveAttachment(attachmentFile: attachmentToSave, attachmentPath: attachmentPath);
  }

  Future<String> _saveAttachment({required File attachmentFile, required String attachmentPath}) async {
    final attachment = await pathBuilder.getAttachmentFromStorage(attachmentPath);

    await attachment.parent.create(recursive: true);
    final tempFile = fs.file('${attachment.path}.tmp.${DateTime.now().microsecondsSinceEpoch}');
    final bytes = await attachmentFile.readAsBytes();
    await tempFile.writeAsBytes(bytes, flush: true);

    const maxAttempts = 5;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        await tempFile.rename(attachment.path);
        break;
      } catch (_) {
        try {
          if (await attachment.exists()) {
            await attachment.delete();
          }
        } catch (_) {
          // Ignore; we'll backoff and retry.
        }

        if (attempt == maxAttempts) {
          rethrow;
        }

        // Exponential backoff: 50ms, 100ms, 150ms, ...
        await Future<void>.delayed(Duration(milliseconds: 50 * attempt));
      }
    }

    return attachment.path;
  }
}
