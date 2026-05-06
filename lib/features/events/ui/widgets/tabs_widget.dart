import 'package:events/core/extension/navigator_extension.dart';
import 'package:events/features/auth/ui/login_page.dart';
import 'package:events/features/events/cubit/event_cubit.dart';
import 'package:events/features/events/model/event_model.dart';
import 'package:events/features/add_new_event/ui/add_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TabsWidget extends StatelessWidget {
  const TabsWidget({this.onNewEventAdded, super.key});
  final void Function(EventModel eventModel)? onNewEventAdded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const TabTile(
            label: 'همه',
          ),
          const SizedBox(width: 8),
          TabTile(label: EventType.kids.name, index: 0),
          const SizedBox(width: 8),
          TabTile(label: EventType.teens.name, index: 1),
          const SizedBox(width: 8),
          TabTile(
              label: 'افزودن',
              index: 3,
              icon: Icons.add,
              onTap: () {
                if (onNewEventAdded == null) {
                  context.navigatorPush(const LoginPage());
                  return;
                }
                context.navigatorPush(AddEventScreen(onAdded: onNewEventAdded));
              }),
        ],
      ),
    );
  }
}

class TabTile extends StatelessWidget {
  const TabTile({required this.label, this.index = -1, this.icon, this.onTap, super.key});
  final int index;
  final VoidCallback? onTap;
  final IconData? icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCubit, EventState>(
      builder: (context, state) {
        final selected = context.read<EventCubit>().selectedTab == index;

        return Expanded(
          child: InkWell(
            onTap: () {
              onTap?.call();
              if (onTap == null) {
                context.read<EventCubit>().onTapChanged(index);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected ? Theme.of(context).primaryColor : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: selected ? Colors.white : Colors.black87),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
