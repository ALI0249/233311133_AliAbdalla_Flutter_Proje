class TicketType {
  final int id;
  final String name;
  final double price;

  const TicketType({
    required this.id,
    required this.name,
    required this.price,
  });

  factory TicketType.fromMap(Map<String, dynamic> map) {
    return TicketType(
      id: (map['id'] as num).toInt(),
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
    );
  }
}
