class Artifact {
  final String id;
  final String museumId;
  final String name;
  final String category;
  final String? era;
  final String? description;
  final String? locationInMuseum;
  final String? imageUrl;
  final String qrPayload;

  const Artifact({
    required this.id,
    required this.museumId,
    required this.name,
    required this.category,
    this.era,
    this.description,
    this.locationInMuseum,
    this.imageUrl,
    required this.qrPayload,
  });

  factory Artifact.fromMap(Map<String, dynamic> map) {
    return Artifact(
      id: map['id'] as String,
      museumId: map['museum_id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      era: map['era'] as String?,
      description: map['description'] as String?,
      locationInMuseum: map['location_in_museum'] as String?,
      imageUrl: map['image_url'] as String?,
      qrPayload: map['qr_payload'] as String,
    );
  }
}

const List<String> kArtifactCategories = [
  'Sanat',
  'Tarih',
  'Heykel',
  'Arkeoloji',
  'Etnografya',
  'El Yazmasi',
];
