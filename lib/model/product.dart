class Product {
  final String id;
  final String title;
  final String group;
  final String desc;
  final List<String> tool;
  final List<String> imageURL;

  /// Automatically set by DB (Supabase).
  final DateTime? createdAt;

  /// Null means never edited after creation.
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.title,
    required this.group,
    required this.desc,
    required this.tool,
    required this.imageURL,
    this.createdAt,
    this.updatedAt,
  });
  Product copyWith({
    String? id,
    String? title,
    String? group,
    String? desc,
    List<String>? tool,
    List<String>? imageURL,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      group: group ?? this.group,
      desc: desc ?? this.desc,
      tool: tool ?? this.tool,
      imageURL: imageURL ?? this.imageURL,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    final s = v.toString();
    return DateTime.tryParse(s);
  }
  factory Product.fromMap(Map<String, dynamic> map) => Product.fromJson(map);
  Map<String, dynamic> toMap() => toJson();
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'group': group,
      'desc': desc,
      'tool': tool,
      'imageURL': imageURL,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> map) {
    return Product(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      group: (map['group'] ?? '').toString(),
      desc: (map['desc'] ?? '').toString(),
      tool: List<String>.from(map['tool'] ?? const []),
      imageURL: List<String>.from(map['imageURL'] ?? map['image_urls'] ?? const []),
      createdAt: _parseDate(map['created_at']),
      updatedAt: _parseDate(map['updated_at']),
    );
  }
}
