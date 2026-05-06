import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MainCacheManager extends CacheManager with ImageCacheManager {
  factory MainCacheManager() {
    return _instance;
  }

  MainCacheManager._()
      : super(
          Config(
            key,
            stalePeriod: const Duration(days: 360),
            maxNrOfCacheObjects: 5000,
          ),
        );

  static const key = 'mainCachedImageData';

  static final _instance = MainCacheManager._();
}

extension MainCacheManagerExtension on CacheManager {
  Future<bool> ensureInCache(
    String url, {
    String? key,
    Map<String, String>? headers,
  }) async {
    key ??= url;
    try {
      final cacheFile = await getFileFromCache(key);
      if (!(cacheFile != null && cacheFile.validTill.isAfter(DateTime.now()) && await cacheFile.file.exists())) {
        await downloadFile(url, key: key, authHeaders: headers);
      }
    } catch (e) {
      return false;
    }

    return true;
  }
}
