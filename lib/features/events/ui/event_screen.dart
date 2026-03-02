import 'package:events/core/widgets/cached_image.dart';
import 'package:events/features/events/cubit/event_cubit.dart';
import 'package:events/features/events/model/event_model.dart';
import 'package:events/features/events/repository/event_repository.dart';
import 'package:events/features/events/services/event_services.dart';
import 'package:events/features/events/ui/event_detail_screen.dart';
import 'package:events/features/events/ui/widgets/tabs_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void showOfflineMsg() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('شما افلاین هستید ، اتصال خود را بررسی کنید'),
        backgroundColor: Colors.red.shade600,
      ),
    );
  }

  // Future<void> _logout() async {
  //   // final ac = Get.find<AuthController>();
  //
  //   try {
  //     // await ac.signOut();
  //     // Get.offAll(() => const LoginOrRegister());
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: const Text('شما موفقانه از حساب خویش خارج شدید!'),
  //         backgroundColor: Colors.green.shade600,
  //       ),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: const Text('خطا در خروج از سیستم!'),
  //         backgroundColor: Colors.red.shade600,
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final eventRepository = context.read<EventRepository>();
    final eventServices = EventServices(eventRepository);

    return Scaffold(
      appBar: AppBar(
        title: const Text('صفحه برنامه ها'),
        actions: [
          if (kDebugMode)
            InkWell(
              onTap: () async {
                await eventServices.deleteAll();
                if (context.mounted) {
                  context.read<EventRepository>().deleteAll();
                }
              },
              child: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
            )
        ],
      ),
      body: SafeArea(
        child: BlocProvider(
          create: (context) => EventCubit(eventRepository: eventRepository, eventServices: eventServices)..reload(),
          child: Builder(builder: (context) {
            return BlocBuilder<EventCubit, EventState>(
              builder: (context, state) {
                return Column(
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                    //   child: TextField(
                    //     controller: _searchCtrl,
                    //     onChanged: (_) => setState(() {}),
                    //     decoration: InputDecoration(
                    //       hintText: 'جستجو...',
                    //       prefixIcon: const Icon(Icons.search),
                    //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    //     ),
                    //   ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TabsWidget(onNewEventAdded: (_) {
                        context.read<EventCubit>().reload();
                      }),
                    ),
                    const SizedBox(height: 6),
                    const Expanded(child: EventsList()),
                  ],
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

class EventsList extends StatelessWidget {
  const EventsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCubit, EventState>(builder: (context, state) {
      if (state is EventListEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              Icon(
                Icons.do_not_disturb_alt_outlined,
                color: Colors.grey,
                size: 100,
              ),
              Text(
                'لیست برنامه ها خالیست!',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 16),
              )
            ],
          ),
        );
      }
      if (state is EventLoaded) {
        final events = state.events;

        return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              return EventCard(
                eventModel: events[index],
              );
            });
      }
      return const Center(
        child: CircularProgressIndicator(),
      );
    });
  }
}

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.eventModel});
  final EventModel eventModel;

  Widget thumb() {
    final firstImage = eventModel.imagePaths.isEmpty ? '' : eventModel.imagePaths.first;

    if (firstImage.isEmpty) {
      return const Icon(Icons.image, color: Colors.grey, size: 40);
    }
    return CachedImage(
      url: firstImage,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EventDetailScreen(
                      eventModel: eventModel,
                      onUpdated: () {
                        context.read<EventCubit>().reload();
                      },
                    )));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                DecoratedBox(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(width: 1.5, color: Theme.of(context).primaryColor)),
                  child: Padding(
                    padding: const EdgeInsets.all(1),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: SizedBox(width: 65, height: 65, child: thumb()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(eventModel.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(eventModel.desc.toString(), style: TextStyle(color: Colors.grey.shade700)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
