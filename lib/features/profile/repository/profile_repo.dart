import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:events/core/model/profile.dart';

class ProfileRepo {
  ProfileRepo(this._client);
  final SupabaseClient _client;

  Future<Profile?> fetchMyProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final res = await _client.from('profiles').select('id,email,role,is_active').eq('id', user.id).maybeSingle();

    if (res == null) return null;
    return Profile.fromJson(res);
  }

  /// ساخت پروفایل اگر وجود ندارد (برای عبور از policy های products).
  /// نقش (role) را دیگر در اپ استفاده نمی‌کنیم، ولی ستونش در DB وجود دارد.
  Future<void> ensureProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final existing = await _client.from('profiles').select('id').eq('id', user.id).maybeSingle();
    if (existing != null) return;

    await _client.from('profiles').insert({
      'id': user.id,
      'email': user.email,
      'is_active': true,
      // role را نزنیم تا default خود DB اعمال شود
    });
  }
}
