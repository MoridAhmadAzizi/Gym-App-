part of 'auth_cubit.dart';

class AppAuthState extends Equatable {
  final sb.Session? session;
  final Profile? profile;
  final bool isLoading;
  final String? message;

  const AppAuthState._({
    required this.isLoading,
    this.session,
    this.profile,
    this.message,
  });

  const AppAuthState.unknown() : this._(isLoading: true);

  const AppAuthState.unauthenticated({String? message})
      : this._(isLoading: false, session: null, profile: null, message: message);

  const AppAuthState.authenticated({
    required sb.Session session,
    Profile? profile,
    String? message,
  }) : this._(
    isLoading: false,
    session: session,
    profile: profile,
    message: message,
  );

  bool get isAuthenticated => session != null;

  bool get isBlocked => profile != null && !profile!.isActive;

  @override
  List<Object?> get props =>
      [session?.user.id, profile?.roleNormalized, profile?.isActive, isLoading, message];
}
