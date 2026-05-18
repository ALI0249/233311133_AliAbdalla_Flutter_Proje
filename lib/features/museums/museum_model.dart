class Museum {
  final String id;
  final String name;
  final String? city;
  final String? address;
  final String? openingHours;
  final String? description;

  const Museum({
    required this.id,
    required this.name,
    this.city,
    this.address,
    this.openingHours,
    this.description,
  });

  factory Museum.fromMap(Map<String, dynamic> map) {
    return Museum(
      id: map['id'] as String,
      name: map['name'] as String,
      city: map['city'] as String?,
      address: map['address'] as String?,
      openingHours: map['opening_hours'] as String?,
      description: map['description'] as String?,
    );
  }
}

class Exhibition {
  final String id;
  final String museumId;
  final String title;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? description;

  const Exhibition({
    required this.id,
    required this.museumId,
    required this.title,
    this.startDate,
    this.endDate,
    this.description,
  });

  factory Exhibition.fromMap(Map<String, dynamic> map) {
    return Exhibition(
      id: map['id'] as String,
      museumId: map['museum_id'] as String,
      title: map['title'] as String,
      startDate: map['start_date'] == null
          ? null
          : DateTime.parse(map['start_date'] as String),
      endDate: map['end_date'] == null
          ? null
          : DateTime.parse(map['end_date'] as String),
      description: map['description'] as String?,
    );
  }
}
