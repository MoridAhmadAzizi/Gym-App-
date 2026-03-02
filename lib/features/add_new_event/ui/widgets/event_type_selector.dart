import 'package:events/features/add_new_event/cubit/add_event_cubit.dart';
import 'package:events/features/events/model/event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventTypeSelector extends StatelessWidget {
  const EventTypeSelector({this.eventType = 0, super.key});
  final int eventType;
  List<EventType> get types => [EventType.kids, EventType.teens];

  @override
  Widget build(BuildContext context) {
    final selectedType = EventType.isForKids(eventType) ? EventType.kids : EventType.teens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('بخش', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: Colors.grey[300]!, width: 2),
          ),
          child: DropdownButton<EventType>(
            value: selectedType,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.expand_more, color: Colors.grey),
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            items: types.map((eventType) {
              return DropdownMenuItem<EventType>(
                value: eventType,
                child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(eventType.name)),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                context.read<AddEventCubit>().changeEventType(newValue.type);
              }
            },
          ),
        ),
      ],
    );
  }
}
