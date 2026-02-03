part of 'users_cubit.dart';

class UsersState extends Equatable {
  final bool loading;
  final List<Profile> users;
  final String? errorMessage;

  const UsersState._({required this.loading, required this.users, this.errorMessage});

  const UsersState.loading() : this._(loading: true, users: const []);

  const UsersState.ready(List<Profile> users) : this._(loading: false, users: users);

  const UsersState.error(String message)
      : this._(loading: false, users: const [], errorMessage: message);

  @override
  List<Object?> get props => [loading, users, errorMessage];
}
