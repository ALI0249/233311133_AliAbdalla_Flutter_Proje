class Profile {
  final String id;
  final String fullName;
  final String? phone;
  final String role;
  final DateTime createdAt;

  const Profile({
    required this.id,
    required this.fullName,
    this.phone,
    required this.role,
    required this.createdAt,
  });

  bool get isPersonel => role == 'personel';
  bool get isZiyaretci => role == 'ziyaretci';

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      fullName: map['full_name'] as String? ?? '',
      phone: map['phone'] as String?,
      role: map['role'] as String? ?? 'ziyaretci',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
