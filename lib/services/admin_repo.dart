import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wahab/model/profile.dart';

class AdminRepo {
  AdminRepo(this._client);
  final SupabaseClient _client;

  Future<List<Profile>> listUsers() async {
    final data = await _client
        .from('profiles')
        .select('id,email,role,is_active')
        .order('email', ascending: true);

    return (data as List)
        .cast<Map<String, dynamic>>()
        .map(Profile.fromJson)
        .toList();
  }

  Future<void> setActive({required String userId, required bool isActive}) async {
    await _client.rpc('admin_set_user_active', params: {
      'target_user': userId,
      'is_active': isActive,
    });
  }

  Future<void> setRole({required String userId, required String role}) async {
    await _client.rpc('admin_set_user_role', params: {
      'target_user': userId,
      'new_role': role,
    });
  }

  /// حذف کامل: نیازمند Edge Function با Service Role (سمت سرور)
  Future<void> deleteUser({required String userId}) async {
    await _client.functions.invoke('admin_delete_user', body: {
      'user_id': userId,
    });
  }
}
