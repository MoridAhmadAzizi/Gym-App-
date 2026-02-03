import 'dart:typed_data';

import 'package:objectbox/objectbox.dart';

/// ذخیره‌ی باینری عکس برای حالت آفلاین.
///
/// - `remoteUrl` آدرس اصلی در Supabase Storage
/// - `bytes` فایل فشرده‌شده‌ی تصویر
@Entity()
class ProductImageEntity {
  @Id()
  int obId;

  @Index()
  String remoteUrl;

  /// ObjectBox از Uint8List پشتیبانی می‌کند.
  Uint8List bytes;

  ProductImageEntity({
    this.obId = 0,
    required this.remoteUrl,
    required this.bytes,
  });
}
