part of 'event_cubit.dart';

@immutable
sealed class EventState extends Equatable {
  @override
  List<Object> get props => [];
}

final class EventLoading extends EventState {}

final class EventLoaded extends EventState {
  EventLoaded(this.events);
  final List<EventModel> events;
  @override
  List<Object> get props => [events];
}

final class EventListEmpty extends EventState {
  EventListEmpty();
}
