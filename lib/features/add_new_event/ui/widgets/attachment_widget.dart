import 'package:events/core/widgets/fitted_text.dart';
import 'package:events/features/add_new_event/cubit/add_event_cubit.dart';
import 'package:events/features/events/model/attachments_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'attachment_widget_with_type.dart';

class AttachmentWidgets extends StatelessWidget {
  const AttachmentWidgets(this.attachments, {super.key});
  final List<AttachmentsModel> attachments;
  static const int attachmentLimit = 3;

  @override
  Widget build(BuildContext context) {
    final addEventCubit = context.read<AddEventCubit>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'ضمیمه ها',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black87),
              ),
              const Spacer(),
              Text('${attachments.length}/$attachmentLimit', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: (attachments.length >= attachmentLimit) ? null : addEventCubit.attachFiles,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                ),
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 18, color: Colors.white),
                label: Text(attachments.isEmpty ? 'انتخاب' : 'افزودن', style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (attachments.isEmpty)
            GestureDetector(
              onTap: addEventCubit.attachFiles,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 42, color: Colors.grey),
                    SizedBox(height: 10),
                    Text('حد مجاز برای انتخاب ضمیمه الی $attachmentLimit عدد.', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: attachments.length,
                separatorBuilder: (_, __) => const SizedBox(width: 0),
                itemBuilder: (context, index) {
                  final attache = attachments[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
                    child: SizedBox(
                      width: 96,
                      height: 96,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: ColoredBox(
                              color: Colors.grey.shade100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  AttachmentWidgetWithType(attache.dataType.toUpperCase()),
                                  FittedText(
                                    attache.name,
                                    maxLines: 2,
                                  )
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: -10,
                            right: -10,
                            child: InkWell(
                              onTap: () => addEventCubit.removeAttachmentFromList(index),
                              borderRadius: BorderRadius.circular(999),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: DecoratedBox(
                                    decoration: BoxDecoration(color: Colors.black.withAlpha(150), shape: BoxShape.circle),
                                    child: const Icon(Icons.close, size: 16, color: Colors.white)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
