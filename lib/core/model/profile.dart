class Profile {
  final String id;
  final String email;
  final bool isActive;

  /// role exists in DB, but app logic no longer uses it.
  final String? role;

  const Profile({
    required this.id,
    required this.email,
    required this.isActive,
    this.role,
  });

  factory Profile.fromJson(Map<String, dynamic> map) {
    return Profile(
      id: (map['id'] ?? '').toString(),
      email: (map['email'] ?? '').toString().trim().toLowerCase(),
      isActive: (map['is_active'] ?? true) == true,
      role: map['role']?.toString(),
    );
  }
}
