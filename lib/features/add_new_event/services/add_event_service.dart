import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:events/features/events/model/attachments_model.dart';
import 'package:events/features/events/model/event_model.dart';
import 'package:events/supabase_config.dart';
import 'package:events/utils/image_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddEventService {
  bool _isRemoteUrl(String s) => s.startsWith('http://') || s.startsWith('https://');

  Future<List<String>> _uploadImagesIfNeeded({required int eventId, required List<String> images}) async {
    final supabase = Supabase.instance.client;

    final imageUrls = <String>[];
    final storage = supabase.storage.from(SupabaseConfig.imageBucket);

    for (var i = 0; i < images.length; i++) {
      final img = images[i];
      if (img.isEmpty) continue;
      if (_isRemoteUrl(img)) {
        imageUrls.add(img);
        continue;
      }

      final normalized = img.startsWith('file://') ? img.replaceFirst('file://', '') : img;
      if (!File(normalized).existsSync()) continue;
      final bytes = await ImageUtils.compressToJpegBytes(normalized);
      final path = '${eventId}_${DateTime.now().millisecondsSinceEpoch}_$i.jpeg';

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
      imageUrls.add(publicUrl);
    }

    return imageUrls;
  }

  Future<String> uploadAttachmentsIfNeeded({required int eventId, required List<AttachmentsModel> attachments}) async {
    final supabase = Supabase.instance.client;

    final atthachmentsUrl = <AttachmentsModel>[];
    final storage = supabase.storage.from(SupabaseConfig.attachmentsBucket);

    for (var i = 0; i < attachments.length; i++) {
      final attachment = attachments[i];
      final attachmentPath = attachment.path;
      if (attachmentPath.isEmpty) continue;
      if (_isRemoteUrl(attachmentPath)) {
        atthachmentsUrl.add(attachment);
        continue;
      }

      final normalized = attachmentPath.startsWith('file://') ? attachmentPath.replaceFirst('file://', '') : attachmentPath;
      final localeFile = File(normalized);
      if (!localeFile.existsSync()) continue;
      final path = '$eventId/${attachment.name}.${attachment.dataType}';
      await storage.upload(
        path,
        localeFile,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: true,
        ),
      );

      final publicUrl = storage.getPublicUrl(path);
      final updatedAttachment = attachment.copyWith(path: publicUrl);
      atthachmentsUrl.add(updatedAttachment);
    }
    final mapped = AttachmentsModel.listToJson(atthachmentsUrl);
    final encoded = jsonEncode(mapped);
    return encoded;
  }

  Future<EventModel?> upsert(EventModel eventModel) async {
    final supabase = Supabase.instance.client;

    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    return _insertRemote(supabase, eventModel);
  }

  Future<EventModel?> update(EventModel eventModel) async {
    final supabase = Supabase.instance.client;

    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    return _updateRemote(supabase, eventModel);
  }

  Future<EventModel?> _insertRemote(SupabaseClient supabaseClient, EventModel eventModel) async {
    try {
      final urls = await _uploadImagesIfNeeded(
        eventId: eventModel.id,
        images: eventModel.imagePaths,
      );
      final attachment = await uploadAttachmentsIfNeeded(eventId: eventModel.id, attachments: eventModel.attachments);

      final inserted = await supabaseClient
          .from('products')
          .insert({
            'title': eventModel.title,
            'description': eventModel.desc,
            'type': eventModel.type,
            'status': eventModel.status,
            'tools': eventModel.tools,
            'image_paths': urls,
            'attachments': attachment,
          })
          .select('id,title,description,type,tools,image_paths,attachments,created_at,updated_at')
          .single();

      final postedEvent = EventModel.formJson(inserted);

      return postedEvent;
    } catch (e) {
      developer.log('posting new event error is: $e}');
      return null;
    }
  }

  Future<EventModel> _updateRemote(
    SupabaseClient supabase,
    EventModel eventModel,
  ) async {
    final urls = await _uploadImagesIfNeeded(
      eventId: eventModel.id,
      images: eventModel.imagePaths,
    );
    final attachment = await uploadAttachmentsIfNeeded(eventId: eventModel.id, attachments: eventModel.attachments);

    final updatedEvent = eventModel.copyWith(imagePaths: urls);
    final postedData = await supabase
        .from('products')
        .update({
          'title': updatedEvent.title,
          'description': updatedEvent.desc,
          'type': updatedEvent.type,
          'tools': updatedEvent.tools,
          'status': updatedEvent.status,
          'image_paths': urls,
          'attachments': attachment,
        })
        .eq('id', updatedEvent.id)
        .select('id,title,description,type,tools,image_paths,attachments,created_at,updated_at');
    developer.log('postedData is: $postedData} ${updatedEvent.title}');
    return updatedEvent;
  }
}
