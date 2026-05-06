import 'package:events/features/events/model/attachments_model.dart';
import 'package:objectbox/objectbox.dart';

enum EventStatus {
  active('فعال', 0),
  deActive('غیر فعال', 1),
  deleted('حذف شده', 2);

  const EventStatus(this.name, this.status);
  final String name;
  final int status;
}

enum EventType {
  kids('نونهالان', 0),
  teens('نوجوانان', 1);

  const EventType(
    this.name,
    this.type,
  );
  final String name;
  final int type;
  static bool isForKids(int type) => type == EventType.kids.type;
  static bool isForTeens(int type) => type == EventType.teens.type;
}

@Entity()
class EventModel {
  @Id(assignable: true)
  int id;

  final String title;
  final int type;
  final String desc;
  final List<String> tools;
  final List<String> imagePaths;
  @Property(type: PropertyType.date)
  final DateTime? createdAt;
  @Property(type: PropertyType.date)
  final DateTime? updatedAt;
  final int status;
  final String dbAttachment;

  @Transient()
  List<AttachmentsModel> attachments = <AttachmentsModel>[];

  EventModel({
    this.id = 0,
    this.title = '',
    this.type = 0,
    this.desc = '',
    this.status = 0,
    this.tools = const [],
    this.imagePaths = const [],
    this.dbAttachment = '',
    this.createdAt,
    this.updatedAt,
  }) {
    if (dbAttachment.isNotEmpty) {
      attachments = AttachmentsModel.decodeAttachments(dbAttachment);
    }
  }

  static EventModel get empty => EventModel();
  EventModel copyWith({
    int? id,
    String? title,
    String? group,
    String? desc,
    int? type,
    List<String>? tools,
    List<String>? imagePaths,
    String? dbAttachment,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? status,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      desc: desc ?? this.desc,
      tools: tools ?? this.tools,
      imagePaths: imagePaths ?? this.imagePaths,
      dbAttachment: dbAttachment ?? this.dbAttachment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  factory EventModel.formJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: (json['title'] ?? '').toString(),
      type: (json['type'] ?? 0) as int,
      desc: (json['description'] ?? '').toString(),
      tools: List<String>.from(json['tools'] ?? const <String>[]),
      imagePaths: List<String>.from(json['image_paths'] ?? const <String>[]),
      dbAttachment: (json['attachments'] ?? '') as String,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      status: (json['status'] ?? 0) as int,
    );
  }
}
