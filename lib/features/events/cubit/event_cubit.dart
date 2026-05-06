import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:events/features/events/model/event_model.dart';
import 'package:events/features/events/repository/event_repository.dart';
import 'package:events/features/events/services/event_services.dart';
import 'package:flutter/material.dart';

part 'event_state.dart';

class EventCubit extends Cubit<EventState> {
  EventCubit({required this.eventRepository, required this.eventServices}) : super(EventLoading());
  final EventRepository eventRepository;
  final EventServices eventServices;
  int selectedTab = -1;
  Future<void> reload() async {
    emit(EventLoading());

    final events = await eventServices.reloadEvents();
    if (events.isNotEmpty) {
      emit(EventLoaded(events));
      return;
    }
    emit(EventListEmpty());
  }

  void onTapChanged(int chantedTab) {
    selectedTab = chantedTab;
    if (chantedTab == -1) {
      reload();
      return;
    }
    final dbEvents = eventRepository.getActiveEvents();
    if (dbEvents.isNotEmpty) {
      final sortedEvents = dbEvents.where((event) => event.type == selectedTab);
      if (sortedEvents.isNotEmpty) {
        emit(EventLoaded(sortedEvents.toList()));
        return;
      }
    }
    emit(EventListEmpty());
  }
}
