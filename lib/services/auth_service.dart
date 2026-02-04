// lib/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class AuthService {
  AuthService(this._client);

  final sb.SupabaseClient _client;

  sb.Session? get session => _client.auth.currentSession;
  sb.User? get currentUser => _client.auth.currentUser;

  Stream<sb.AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUpAndSendOtp({
    required String email,
    required String password,
  }) async {
    await _client.auth.signUp(email: email, password: password);
  }

  Future<sb.AuthResponse> verifySignupOtp({
    required String email,
    required String token,
  }) async {
    return _client.auth.verifyOTP(
      type: sb.OtpType.signup,
      email: email,
      token: token,
    );
  }

  Future<void> resendSignupOtp({
    required String email,
  }) async {
    await _client.auth.resend(
      type: sb.OtpType.signup,
      email: email,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
