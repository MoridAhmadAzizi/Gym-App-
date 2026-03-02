import 'dart:developer' as developer;
import 'package:events/core/providers/local_image_provider.dart';
import 'package:events/features/events/model/attachments_model.dart';
import 'package:events/features/events/model/event_model.dart';
import 'package:events/objectbox.g.dart';

class EventRepository {
  const EventRepository(this.eventBox, this.localImageProvider);
  final Box<EventModel> eventBox;
  final LocalImageProvider localImageProvider;

  List<EventModel> getActiveEvents() {
    final query = eventBox.query().build();
    final events = query.find();
    query.close();
    developer.log('data base length is: ${events.length}');
    return events;
  }

  EventModel? getEventById(int id) {
    final query = eventBox.get(id);
    return query;
  }

  bool _isRemote(url) => url.startsWith('http://') || url.startsWith('https://');
  void deleteAll() {
    eventBox.removeAll();
  }

  Future<void> storeEvents(List<EventModel> events) async {
    for (final event in events) {
      final dbEvent = getEventById(event.id);

      if (dbEvent == null) {
        if (event.imagePaths.isEmpty) {
          eventBox.put(event);
          return;
        }
        eventBox.put(await _updateEventImages(event));
      } else {
        if (dbEvent.updatedAt != event.updatedAt) {
          eventBox.put(await _updateEventImages(event));
        }
      }
    }
  }

  Future<List<String>> _storeImages(List<String> imageUrls) async {
    final images = List<String>.from(imageUrls);

    for (var i = 0; i < images.length; i++) {
      final imageUrl = images[i];
      if (_isRemote(imageUrl)) {
        final imagePath = await localImageProvider.saveImage(imageUrl);
        images[i] = imagePath;
      }
    }
    return images;
  }

  Future<List<AttachmentsModel>> _storeAttachments(List<AttachmentsModel> attachments) async {
    final attachmentsList = List<AttachmentsModel>.from(attachments);

    for (var i = 0; i < attachmentsList.length; i++) {
      final attachmentUrl = attachmentsList[i].path;
      if (_isRemote(attachmentUrl)) {
        final savedAttachmentPath = await localImageProvider.saveAttachment(attachmentUrl);
        attachmentsList[i] = attachmentsList[i].copyWith(path: savedAttachmentPath);
      }
    }
    return attachmentsList;
  }

  Future<EventModel> _updateEventImages(EventModel event) async {
    final storedImages = await _storeImages(event.imagePaths);
    final storedAttachments = await _storeAttachments(event.attachments);
    final encodedAttachments = AttachmentsModel.encodeAttachments(storedAttachments);

    final updatedEvent = event.copyWith(imagePaths: storedImages, dbAttachment: encodedAttachments);
    developer.log('saving image: ${event.title} image: ${updatedEvent.imagePaths}, attachments: ${updatedEvent.dbAttachment}');
    return updatedEvent;
  }
}
