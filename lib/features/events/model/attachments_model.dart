import 'dart:convert';

class AttachmentsModel {
  const AttachmentsModel({
    required this.path,
    required this.dataType,
    required this.name,
  });

  final String path;
  final String dataType;
  final String name;
  String get fullName => '$name.$dataType';

  /// ---------- JSON ----------

  factory AttachmentsModel.fromJson(Map<String, dynamic> json) {
    return AttachmentsModel(
      path: json['path'] as String,
      dataType: json['dataType'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'dataType': dataType,
      'name': name,
    };
  }

  /// ---------- COPY ----------

  AttachmentsModel copyWith({
    String? path,
    String? dataType,
    String? name,
  }) {
    return AttachmentsModel(
      path: path ?? this.path,
      dataType: dataType ?? this.dataType,
      name: name ?? this.name,
    );
  }

  /// ---------- HELPERS ----------

  static List<AttachmentsModel> listFromJson(List<dynamic> list) {
    return list.map((e) => AttachmentsModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  static List<Map<String, dynamic>> listToJson(
    List<AttachmentsModel> list,
  ) {
    return list.map((e) => e.toJson()).toList();
  }

  static encodeAttachments(List<AttachmentsModel> attachmentsList) {
    final mappedAttaches = listToJson(attachmentsList);
    final encodedAttaches = jsonEncode(mappedAttaches);
    return encodedAttaches;
  }

  static decodeAttachments(String attachments) {
    final decodedAttachments = jsonDecode(attachments) as List<dynamic>;
    final attachmentsList = decodedAttachments.cast<Map<String, dynamic>>().map(AttachmentsModel.fromJson).toList();
    return attachmentsList;
  }
}
