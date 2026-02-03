import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:wahab/model/profile.dart';
import 'package:wahab/services/auth_services.dart';
import 'package:wahab/services/profile_repo.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AppAuthState> {
  AuthCubit({required AuthService auth, required ProfileRepo profiles})
      : _auth = auth,
        _profiles = profiles,
        super(const AppAuthState.unknown()) {
    _sub = _auth.authStateChanges.listen((_) {
      unawaited(refresh());
    });

    unawaited(refresh());
  }

  final AuthService _auth;
  final ProfileRepo _profiles;
  StreamSubscription<sb.AuthState>? _sub;

  Future<void> refresh() async {
    final session = _auth.session;
    if (session == null) {
      emit(const AppAuthState.unauthenticated());
      return;
    }

    try {
      final profile = await _profiles.fetchMyProfile();

      // اگر پروفایل قابل خواندن نبود (Policy/RLS مشکل دارد)،
      // همچنان session را نگه می‌داریم ولی profile=null می‌ماند.
      // اینجا بهتر است در UI هم پیام مناسب نشان بدهی.
      if (profile == null) {
        emit(AppAuthState.authenticated(session: session, profile: null, message: 'No user'));
        return;
      }

      // اگر inactive است، بیرونش نکن؛ فقط پیام بده.
      if (!profile.isActive) {
        emit(AppAuthState.authenticated(
          session: session,
          profile: profile,
          message: 'حساب شما غیر فعال شده است.',
        ));
        return;
      }

      emit(AppAuthState.authenticated(session: session, profile: profile, message: 'No user'));
    } catch (_) {
      emit(AppAuthState.authenticated(session: session, profile: null, message: 'no user '));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    emit(const AppAuthState.unauthenticated());
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
