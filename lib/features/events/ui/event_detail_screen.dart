import 'package:events/core/extension/navigator_extension.dart';
import 'package:events/features/add_new_event/ui/add_event_screen.dart';
import 'package:events/features/add_new_event/ui/widgets/attachment_widget_with_type.dart';
import 'package:events/features/events/model/event_model.dart';
import 'package:events/features/events/ui/widgets/image_slider.dart';
import 'package:events/utils/date_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key, required this.eventModel, this.onUpdated});
  final EventModel eventModel;
  final VoidCallback? onUpdated;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late ValueNotifier<EventModel> eventModelNotifier = ValueNotifier(widget.eventModel);

  String getEventType(int type) {
    if (EventType.isForKids(type)) {
      return EventType.kids.name;
    }
    return EventType.teens.name;
  }

  bool sharing = false;
  Future<bool> share(String path) async {
    sharing = true;
    final params = ShareParams(
      files: [XFile(path)],
    );

    final result = await SharePlus.instance.share(params);
    sharing = false;

    return result.status == ShareResultStatus.success;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final user = Supabase.instance.client.auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('جزئیات برنامه'),
        actions: [
          if (user != null || kDebugMode)
            InkWell(
              onTap: () {
                context.navigatorPush(AddEventScreen(
                    eventToUpdate: eventModelNotifier.value,
                    onAdded: (postedEvent) {
                      widget.onUpdated?.call();
                      eventModelNotifier.value = postedEvent;
                    }));
              },
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.edit_rounded),
              ),
            ),
        ],
      ),
      body: ValueListenableBuilder(
          valueListenable: eventModelNotifier,
          builder: (context, eventValue, child) {
            final created = eventValue.createdAt;
            final updated = eventValue.updatedAt;
            final showEdited = updated != null && (created == null || updated.isAfter(created));
            final theme = Theme.of(context);
            return Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  spacing: 15,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ImageSlider(eventValue.imagePaths),
                    Text(
                      eventValue.title,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    Text('توضحیات', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                    if (eventValue.desc.isEmpty)
                      Center(child: _chip(context, 'توضیحاتی درباره این محصول وجود ندارد!'))
                    else
                      Text(eventValue.desc, style: theme.textTheme.titleSmall),
                    Text('ابزارها', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        for (final text in eventValue.tools) _chip(context, text),
                        if (eventValue.tools.isEmpty) Center(child: _chip(context, 'هیچ ابزاری هنوز اضافه نشده!')),
                      ],
                    ),
                    if (created != null) Text('ایجاد:  ${DateUtilsFa.dateYmd(created)} - ${DateUtilsFa.timeHm(created)}'),
                    if (showEdited) Text('آخرین ویرایش: ${DateUtilsFa.dateYmd(updated)} - ${DateUtilsFa.timeHm(updated)}'),
                    Text('ضمیمه ها', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                    ...eventValue.attachments.map((attachment) {
                      final path = attachment.path;
                      final startOfAbsolutePath = path.indexOf('/0/');
                      final strippedPath = path.substring(startOfAbsolutePath);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: InkWell(
                          onTap: () {
                            share(attachment.path);
                          },
                          child: Column(
                            children: [
                              Row(spacing: 5, children: [
                                AttachmentWidgetWithType(attachment.dataType),
                                Column(
                                  children: [
                                    Text(
                                      '${attachment.name}.${attachment.dataType}',
                                      maxLines: 1,
                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                const Icon(Icons.share_rounded, color: Colors.grey),
                              ]),
                              SizedBox(
                                  width: screenSize.width * 0.95,
                                  child: Text(
                                    strippedPath,
                                    maxLines: 2,
                                    textDirection: TextDirection.ltr,
                                  )),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Widget _chip(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          )),
    );
  }
}
