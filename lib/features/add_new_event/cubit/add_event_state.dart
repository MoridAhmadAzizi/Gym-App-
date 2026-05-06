part of 'add_event_cubit.dart';

@immutable
sealed class AddEventState {
  const AddEventState(this.eventModel);
  final EventModel eventModel;
  List<Object> get props => [eventModel];
}

final class AddEventInitial extends AddEventState {
  const AddEventInitial(super.eventModel);

  @override
  List<Object> get props => [eventModel];
}

final class EventUpdating extends AddEventState {
  const EventUpdating(
    super.eventModel,
  );
  @override
  List<Object> get props => [eventModel];
}

final class EventPosting extends AddEventState {
  const EventPosting(super.eventModel);

  @override
  List<Object> get props => [eventModel];
}

final class EventPostingSuccess extends AddEventState {
  const EventPostingSuccess(this.message, super.eventModel);
  final String message;

  @override
  List<Object> get props => [message, eventModel];
}

final class EventAddingFailed extends AddEventState {
  const EventAddingFailed(this.message, super.eventModel);
  final String message;

  @override
  List<Object> get props => [message, eventModel];
}
