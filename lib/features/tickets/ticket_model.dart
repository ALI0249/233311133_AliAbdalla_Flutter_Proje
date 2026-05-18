class Ticket {
  final String id;
  final String visitorId;
  final String museumId;
  final int ticketTypeId;
  final DateTime visitDate;
  final String status;
  final String qrPayload;
  final double pricePaid;
  final DateTime createdAt;
  final DateTime? usedAt;

  // Joined data (optional)
  final String? ticketTypeName;
  final String? museumName;

  const Ticket({
    required this.id,
    required this.visitorId,
    required this.museumId,
    required this.ticketTypeId,
    required this.visitDate,
    required this.status,
    required this.qrPayload,
    required this.pricePaid,
    required this.createdAt,
    this.usedAt,
    this.ticketTypeName,
    this.museumName,
  });

  bool get isActive => status == 'aktif';
  bool get isUsed => status == 'kullanildi';
  bool get isCancelled => status == 'iptal';

  factory Ticket.fromMap(Map<String, dynamic> map) {
    final ticketType = map['ticket_types'];
    final museum = map['museums'];
    return Ticket(
      id: map['id'] as String,
      visitorId: map['visitor_id'] as String,
      museumId: map['museum_id'] as String,
      ticketTypeId: (map['ticket_type_id'] as num).toInt(),
      visitDate: DateTime.parse(map['visit_date'] as String),
      status: map['status'] as String,
      qrPayload: map['qr_payload'] as String,
      pricePaid: (map['price_paid'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
      usedAt: map['used_at'] == null
          ? null
          : DateTime.parse(map['used_at'] as String),
      ticketTypeName:
          ticketType is Map ? ticketType['name'] as String? : null,
      museumName: museum is Map ? museum['name'] as String? : null,
    );
  }
}
