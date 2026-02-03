import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:objectbox/objectbox.dart' as obx;
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wahab/model/product.dart';
import 'package:wahab/objectbox.g.dart';
import 'package:wahab/objectbox/objectbox.dart';
import 'package:wahab/objectbox/product_entity.dart';
import 'package:wahab/objectbox/product_image_entity.dart';
import 'package:wahab/services/image_utils.dart';
import 'package:wahab/services/supabase_config.dart';

/// ریپو برای محصولات: Sync با Supabase + کش آفلاین در ObjectBox
class ProductRepo {
  ProductRepo({
    required SupabaseClient client,
    required ObjectBoxApp objectBox,
  })  : _client = client,
        _ob = objectBox {
    _initConnectivity();
  }

  final SupabaseClient _client;
  final ObjectBoxApp _ob;

  final ValueNotifier<bool> isOnline = ValueNotifier<bool>(true);
  StreamSubscription<List<ConnectivityResult>>? _connSub;
  RealtimeChannel? _channel;

  // -------------------------
  // Connectivity
  // -------------------------
  Future<void> _initConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    _setOnlineFromResults(results);

    _connSub = Connectivity().onConnectivityChanged.listen((results) {
      _setOnlineFromResults(results);
    });
  }

  void _setOnlineFromResults(List<ConnectivityResult> results) {
    final online = !results.contains(ConnectivityResult.none);
    isOnline.value = online;
    if (online) {
      unawaited(syncFromRemote());
      _startRealtime();
    } else {
      _stopRealtime();
    }
  }

  // -------------------------
  // Watch local cache
  // -------------------------
  Stream<List<Product>> watchProducts() {
    return _ob.watchAllProducts().map((entities) {
      return entities.map((e) => e.toProduct()).toList();
    });
  }

  // -------------------------
  // Remote sync
  // -------------------------
  Future<void> syncFromRemote() async {
    try {
      final data = await _client
          .from('products')
          .select('id,title,group,desc,tool,image_urls,created_at,updated_at')
          .order('created_at', ascending: false);

      final products = (data as List)
          .cast<Map<String, dynamic>>()
          .map((row) => Product.fromJson({
                ...row,
                'imageURL': row['image_urls'],
              }))
          .toList();

      _ob.store.runInTransaction(obx.TxMode.write, () {
        _ob.productBox.removeAll();
        for (final p in products) {
          _ob.productBox.put(ProductEntity.fromProduct(p));
        }
      });

      // Cache images (best-effort)
      for (final p in products) {
        await _cacheImagesForProduct(p);
      }
    } catch (_) {
      // silent: offline / transient
    }
  }

  void _startRealtime() {
    if (_channel != null) return;
    _channel = _client.channel('public:products');
    _channel!
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'products',
          callback: (payload) {
            // برای سادگی: هر تغییر -> sync کامل
            unawaited(syncFromRemote());
          },
        )
        .subscribe();
  }

  void _stopRealtime() {
    final ch = _channel;
    _channel = null;
    if (ch != null) {
      _client.removeChannel(ch);
    }
  }

  // -------------------------
  // CRUD
  // -------------------------
  void offlineError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('شما آفلاین هستید! لطفاً اینترنت را روشن کنید.'),
        backgroundColor: Colors.red.shade600,
      ),
    );
  }

  Future<Product> addProduct({
    required Product draft,
    required String userId,
  }) async {
    // 1) Insert product (without images) to get id
    final inserted = await _client
        .from('products')
        .insert({
          'title': draft.title,
          'group': draft.group,
          'desc': draft.desc,
          'tool': draft.tool,
          'image_urls': <String>[],
          'created_by': userId,
        })
        .select('id,title,group,desc,tool,image_urls,created_at,updated_at')
        .single();

    final productId = inserted['id'].toString();

    // 2) Upload images
    final urls = await _uploadImagesIfNeeded(
      productId: productId,
      userId: userId,
      images: draft.imageURL,
    );

    // 3) Update row with image urls
    final updatedRow = await _client
        .from('products')
        .update({
          'image_urls': urls,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', productId)
        .select('id,title,group,desc,tool,image_urls,created_at,updated_at')
        .single();

    final product = Product.fromJson({
      ...updatedRow,
      'imageURL': updatedRow['image_urls'],
    });

    _upsertLocalCache(product);
    await _cacheImagesForProduct(product);
    return product;
  }

  Future<Product> updateProduct({
    required Product product,
    required String userId,
  }) async {
    final urls = await _uploadImagesIfNeeded(
      productId: product.id,
      userId: userId,
      images: product.imageURL,
    );

    final row = await _client
        .from('products')
        .update({
          'title': product.title,
          'group': product.group,
          'desc': product.desc,
          'tool': product.tool,
          'image_urls': urls,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', product.id)
        .select('id,title,group,desc,tool,image_urls,created_at,updated_at')
        .single();

    final updated = Product.fromJson({
      ...row,
      'imageURL': row['image_urls'],
    });

    _upsertLocalCache(updated);
    await _cacheImagesForProduct(updated);
    return updated;
  }

  // -------------------------
  // Image: upload + cache (ObjectBox)
  // -------------------------
  bool _isRemoteUrl(String s) => s.startsWith('http://') || s.startsWith('https://');

  Future<List<String>> _uploadImagesIfNeeded({
    required String productId,
    required String userId,
    required List<String> images,
  }) async {
    final out = <String>[];
    final storage = _client.storage.from(SupabaseConfig.imageBucket);

    for (var i = 0; i < images.length; i++) {
      final img = images[i];
      if (img.isEmpty) continue;
      if (img.startsWith('assets/')) continue; // assets را آپلود نمی‌کنیم
      if (_isRemoteUrl(img)) {
        out.add(img);
        continue;
      }

      // local file -> compress -> upload
      final normalized = img.startsWith('file://') ? img.replaceFirst('file://', '') : img;
      final bytes = await ImageUtils.compressToJpegBytes(normalized);
      final ext = '.jpg';
      final path = '$userId/$productId/${DateTime.now().millisecondsSinceEpoch}_$i$ext';

      await storage.uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: true,
          contentType: 'image/jpeg',
        ),
      );

      final publicUrl = storage.getPublicUrl(path);
      out.add(publicUrl);

      // cache bytes locally in objectbox
      _upsertImageCache(publicUrl, bytes);
    }

    return out;
  }

  Future<void> _cacheImagesForProduct(Product p) async {
    // فقط برای URLهای remote
    for (final url in p.imageURL) {
      if (!_isRemoteUrl(url)) continue;
      final existing = _findImageCache(url);
      if (existing != null) continue;

      try {
        final resp = await http.get(Uri.parse(url));
        if (resp.statusCode == 200) {
          _upsertImageCache(url, resp.bodyBytes);
        }
      } catch (_) {
        // ignore
      }
    }
  }

  ProductImageEntity? _findImageCache(String remoteUrl) {
    final q = _ob.imageBox.query(ProductImageEntity_.remoteUrl.equals(remoteUrl)).build();
    final found = q.findFirst();
    q.close();
    return found;
  }

  void _upsertImageCache(String remoteUrl, Uint8List bytes) {
    final existing = _findImageCache(remoteUrl);
    final e = ProductImageEntity(remoteUrl: remoteUrl, bytes: bytes);
    if (existing != null) {
      e.obId = existing.obId;
    }
    _ob.imageBox.put(e);
  }

  /// برای UI: اگر در ObjectBox کش هست bytes را بده
  Uint8List? getCachedBytes(String remoteUrl) {
    return _findImageCache(remoteUrl)?.bytes;
  }

  void _upsertLocalCache(Product product) {
    final q = _ob.productBox.query(ProductEntity_.firebaseId.equals(product.id)).build();
    final existing = q.findFirst();
    q.close();

    final entity = ProductEntity.fromProduct(product);
    if (existing != null) {
      entity.obId = existing.obId;
    }
    _ob.productBox.put(entity);
  }

  Future<void> dispose() async {
    await _connSub?.cancel();
    _stopRealtime();
  }
}
