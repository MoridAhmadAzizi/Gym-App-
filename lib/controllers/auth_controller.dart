// lib/controllers/auth_controller.dart
import 'dart:async';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../model/profile.dart';
import '../services/auth_service.dart';
import '../services/profile_repo.dart';

class AuthController extends GetxController {
  AuthController({required AuthService auth, required ProfileRepo profiles})
      : _auth = auth,
        _profiles = profiles;

  final AuthService _auth;
  final ProfileRepo _profiles;

  final RxBool isLoading = true.obs;
  final Rxn<sb.Session> session = Rxn<sb.Session>();
  final Rxn<Profile> profile = Rxn<Profile>();
  final RxnString message = RxnString();

  StreamSubscription<sb.AuthState>? _sub;

  bool get isAuthenticated => session.value != null;

  @override
  void onInit() {
    super.onInit();
    _sub = _auth.authStateChanges.listen((_) {
      refreshAuth();
    });
    refreshAuth();
  }

  Future<void> refreshAuth() async {
    isLoading.value = true;

    final s = _auth.session;
    session.value = s;

    if (s == null) {
      profile.value = null;
      message.value = null;
      isLoading.value = false;
      return;
    }

    try {
      final p = await _profiles.fetchMyProfile();
      profile.value = p;

      if (p == null) {
        message.value = 'پروفایل یافت نشد';
      } else if (!p.isActive) {
        message.value = 'حساب شما غیر فعال شده است.';
      } else {
        message.value = null;
      }
    } catch (_) {
      profile.value = null;
      message.value = 'خطا در دریافت پروفایل';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    // refreshAuth توسط authStateChanges هم صدا می‌شود
    await refreshAuth();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
