
import 'package:events/features/events/model/event_model.dart';
import 'dart:developer' as developer;
import 'package:events/features/events/repository/event_repository.dart';
import 'package:events/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventServices {
  const EventServices(this.eventRepository);
  final EventRepository eventRepository;
  Future<List<EventModel>> fetchEventsFromServer() async {
    try {
      final supabase = Supabase.instance.client;
      final data = await supabase
          .from(SupabaseConfig.productColumn)
          .select('id,title,description,type,tools,image_paths,created_at,updated_at,attachments, status');

      final events = data.map(EventModel.formJson).where((event) => event.status != EventStatus.deleted.status).toList();
      await eventRepository.storeEvents(events);
      return events;
    } catch (e) {
      developer.log("can't fetch events form server: $e");
    }
    return [];
  }

  Future<void> deleteAll() async {
    final supabase = Supabase.instance.client;
    await supabase.from(SupabaseConfig.productColumn).delete().eq('status', 0);
  }

  Future<List<EventModel>> reloadEvents() async {
    await fetchEventsFromServer();
    return eventRepository.getActiveEvents().toList();
  }
}
