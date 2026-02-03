import 'dart:async';
import 'package:wahab/objectbox.g.dart';
import 'package:wahab/objectbox/product_entity.dart';
import 'package:wahab/objectbox/product_image_entity.dart';

class ObjectBoxApp {
  final Store store;
  late final Box<ProductEntity> productBox;
  late final Box<ProductImageEntity> imageBox;

  ObjectBoxApp._(this.store) {
    productBox = store.box<ProductEntity>();
    imageBox = store.box<ProductImageEntity>();
  }

  static Future<ObjectBoxApp> create() async {
    final store = await openStore();
    return ObjectBoxApp._(store);
  }
  Stream<List<ProductEntity>> watchAllProducts() {
    final controller = StreamController<List<ProductEntity>>();
    Query<ProductEntity>? q;

    final sub = productBox.query().watch(triggerImmediately: true).listen((query) {
      q ??= query;
      controller.add(query.find());
    }, onError: controller.addError);

    controller.onCancel = () async {
      await sub.cancel();
      q?.close();
      await controller.close();
    };

    return controller.stream;
  }
}
