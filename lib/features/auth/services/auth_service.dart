import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService(this._client);

  final SupabaseClient _client;

  Session? get session => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUpAndSendOtp({
    required String email,
    required String password,
  }) async {
    await _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> verifySignupOtp({
    required String email,
    required String token,
  }) async {
    return _client.auth.verifyOTP(
      type: OtpType.signup,
      email: email,
      token: token,
    );
  }

  Future<void> resendSignupOtp({
    required String email,
  }) async {
    await _client.auth.resend(
      type: OtpType.signup,
      email: email,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
