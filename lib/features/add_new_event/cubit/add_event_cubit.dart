import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:events/features/add_new_event/services/add_event_service.dart';
import 'package:events/features/add_new_event/ui/widgets/attachment_widget.dart';
import 'package:events/features/events/model/attachments_model.dart';
import 'package:events/features/events/model/event_model.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as paths;

import 'package:image_picker/image_picker.dart';

part 'add_event_state.dart';

class AddEventCubit extends Cubit<AddEventState> {
  AddEventCubit(this.eventModel) : super(AddEventInitial(eventModel));
  final EventModel eventModel;
  bool saving = false;
  bool pickingImage = false;
  bool attachingFiles = false;
  bool sharing = false;
  EventModel get stateEvent => state.eventModel;

  EventModel addImages(List<String> imagePath) {
    final updatedEvent = stateEvent.copyWith(imagePaths: imagePath);
    emit(EventUpdating(updatedEvent));
    return updatedEvent;
  }

  void removeImageFroList(int index) {
    final updateImageList = List<String>.from(state.eventModel.imagePaths);
    updateImageList.removeAt(index);
    final updatedEvent = stateEvent.copyWith(imagePaths: updateImageList);
    emit(EventUpdating(updatedEvent));
  }

  Future<void> pickImages() async {
    if (pickingImage) return;
    pickingImage = true;
    final picker = ImagePicker();
    final imageList = List<String>.from(stateEvent.imagePaths);
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isEmpty) {
      pickingImage = false;
      return;
    }

    for (final img in images) {
      final path = img.path;
      if (imageList.length >= 10) break;
      if (!imageList.contains(path)) {
        imageList.add(path);
      }
    }
    pickingImage = false;
    final updatedEvent = stateEvent.copyWith(imagePaths: imageList);
    emit(EventUpdating(updatedEvent));
  }

  Future<void> attachFiles() async {
    if (attachingFiles) return;
    attachingFiles = true;
    final picker = ImagePicker();
    final attachmentsList = List<AttachmentsModel>.from(stateEvent.attachments);
    final List<XFile> attachments = await picker.pickMultipleMedia();
    if (attachments.isEmpty) {
      attachingFiles = false;
      return;
    }

    for (final file in attachments) {
      final path = file.path;
      if (attachmentsList.length >= AttachmentWidgets.attachmentLimit) break;
      if (!attachmentsList.any((attachment) => attachment.path == path || attachment.fullName == file.name)) {
        final extension = paths.extension(path).replaceFirst('.', '');
        final fileName = paths.withoutExtension(file.name);

        final attach = AttachmentsModel(path: path, dataType: extension, name: fileName);
        attachmentsList.add(attach);
      }
    }
    attachingFiles = false;
    final mappedAttachments = attachmentsList.map((attach) => attach.toJson()).toList();
    final decodedAttachments = jsonEncode(mappedAttachments);
    final updatedEvent = stateEvent.copyWith(dbAttachment: decodedAttachments);
    emit(EventUpdating(updatedEvent));
  }

  void removeAttachmentFromList(int index) {
    if (stateEvent.dbAttachment.isEmpty) return;
    final List<dynamic> decodedList = jsonDecode(stateEvent.dbAttachment);
    final List<AttachmentsModel> attachmentsList = decodedList.map((e) => AttachmentsModel.fromJson(e)).toList();
    if (index < 0 || index >= attachmentsList.length) return;
    attachmentsList.removeAt(index);
    final updatedJson = jsonEncode(attachmentsList.map((e) => e.toJson()).toList());
    final updatedEvent = stateEvent.copyWith(dbAttachment: updatedJson);
    emit(EventUpdating(updatedEvent));
  }

  void addTool(String toolText) {
    final updatedTools = List<String>.from(stateEvent.tools);
    if (!updatedTools.contains(toolText) && toolText.isNotEmpty) {
      updatedTools.add(toolText);
      final updatedEvent = stateEvent.copyWith(tools: updatedTools);
      emit(EventUpdating(updatedEvent));
    }
  }

  void removeTool(int index) {
    final updatedTools = List<String>.from(stateEvent.tools);
    updatedTools.removeAt(index);
    final updatedEvent = stateEvent.copyWith(tools: updatedTools);
    emit(EventUpdating(updatedEvent));
  }

  void changeEventType(int eventType) {
    final updatedEvent = stateEvent.copyWith(type: eventType);
    emit(EventUpdating(updatedEvent));
  }

  Future<void> submitForm({String title = '', String description = '', bool isEditing = false}) async {
    if (title.isEmpty) {
      emit(EventAddingFailed('لطفاً نام برنامه را وارد کنید', stateEvent));
      return;
    }
    final newEvent = stateEvent.copyWith(title: title, desc: description);

    emit(EventPosting(newEvent));
    saving = true;
    try {
      EventModel? postedEvent;
      if (isEditing) {
        postedEvent = await AddEventService().update(newEvent);
      } else {
        postedEvent = await AddEventService().upsert(newEvent);
      }

      if (postedEvent == null) {
        emit(EventAddingFailed('ثبت برنامه ثبت نشد، دوباره سعی کنید!', stateEvent));
        saving = false;
        return;
      }
      emit(EventPostingSuccess('برنامه موفقانه اضافه شد!', stateEvent));
    } catch (e) {
      debugPrint('posting data error is: $e');
      emit(EventAddingFailed('برنامه ثبت نشد، دوباره سعی کنید!', stateEvent));
    } finally {
      saving = false;
    }
  }

  void restFrom() {
    saving = false;
    pickingImage = false;
    emit(EventUpdating(EventModel.empty));
  }
}
