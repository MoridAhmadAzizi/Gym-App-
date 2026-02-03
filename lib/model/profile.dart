class Profile {
  final String id; // uuid
  final String email;
  final String role; // user | admin | super_admin
  final bool isActive;

  const Profile({
    required this.id,
    required this.email,
    required this.role,
    required this.isActive,
  });

  String get roleNormalized => role.trim().toLowerCase();

  bool get isSuperAdmin => roleNormalized == 'super_admin';
  bool get isAdmin => roleNormalized == 'admin' || roleNormalized == 'super_admin';

  factory Profile.fromJson(Map<String, dynamic> map) {
    return Profile(
      id: (map['id'] ?? '').toString(),
      email: (map['email'] ?? '').toString().trim().toLowerCase(),
      role: (map['role'] ?? 'user').toString().trim().toLowerCase(),
      isActive: (map['is_active'] ?? true) == true,
    );
  }
}
