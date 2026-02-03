import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  /// فشرده‌سازی تصویر (JPEG). خروجی: bytes
  static Future<Uint8List> compressToJpegBytes(
    String originalPath, {
    int quality = 70,
    int minWidth = 1280,
    int minHeight = 1280,
  }) async {
    final out = await FlutterImageCompress.compressWithFile(
      originalPath,
      format: CompressFormat.jpeg,
      quality: quality,
      minWidth: minWidth,
      minHeight: minHeight,
    );
    if (out == null) {
      // fallback: read raw
      return File(originalPath).readAsBytes();
    }
    return out;
  }

  /// اگر لازم بود یک نسخه‌ی فشرده به صورت فایل موقت بسازیم.
  static Future<File> compressToTempFile(String originalPath) async {
    final bytes = await compressToJpegBytes(originalPath);
    final dir = await getTemporaryDirectory();
    final name = 'img_${DateTime.now().millisecondsSinceEpoch}${p.extension(originalPath).isEmpty ? '.jpg' : '.jpg'}';
    final f = File(p.join(dir.path, name));
    await f.writeAsBytes(bytes, flush: true);
    return f;
  }
}
