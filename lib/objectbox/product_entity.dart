import 'package:objectbox/objectbox.dart';
import 'package:wahab/model/product.dart';

import 'package:wahab/objectbox/product_image_entity.dart';

@Entity()
class ProductEntity {
  @Id()
  int obId;

  @Unique()
  /// شناسه رکورد در دیتابیس (قبلاً firebaseId بود، الان Supabase).
  String firebaseId;

  String title;
  String group;
  String desc;

  List<String> tool;
  List<String> imageURL;

  /// Unix millis (برای سازگاری و جلوگیری از مشکلات تبدیل DateTime در ObjectBox)
  int? createdAtMs;
  int? updatedAtMs;

  /// تصاویر کش‌شده برای حالت آفلاین
  final ToMany<ProductImageEntity> images = ToMany<ProductImageEntity>();

  ProductEntity({
    this.obId = 0,
    required this.firebaseId,
    required this.title,
    required this.group,
    required this.desc,
    required this.tool,
    required this.imageURL,
    this.createdAtMs,
    this.updatedAtMs,
  });

  factory ProductEntity.fromProduct(Product p) => ProductEntity(
        firebaseId: p.id,
        title: p.title,
        group: p.group,
        desc: p.desc,
        tool: p.tool,
        imageURL: p.imageURL,
        createdAtMs: p.createdAt?.millisecondsSinceEpoch,
        updatedAtMs: p.updatedAt?.millisecondsSinceEpoch,
      );

  Product toProduct() => Product(
        id: firebaseId,
        title: title,
        group: group,
        desc: desc,
        tool: tool,
        imageURL: imageURL,
        createdAt:
            createdAtMs == null ? null : DateTime.fromMillisecondsSinceEpoch(createdAtMs!),
        updatedAt:
            updatedAtMs == null ? null : DateTime.fromMillisecondsSinceEpoch(updatedAtMs!),
      );
}
