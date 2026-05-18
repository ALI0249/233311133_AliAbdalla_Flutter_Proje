import '../../core/logger.dart';
import '../../core/supabase_client.dart';
import 'ticket_model.dart';
import 'ticket_type_model.dart';

class TicketService {
  Future<List<TicketType>> fetchTypes() async {
    final data =
        await supabase.from('ticket_types').select().order('id');
    return (data as List)
        .map((t) => TicketType.fromMap(t as Map<String, dynamic>))
        .toList();
  }

  Future<Ticket> purchase({
    required String visitorId,
    required String museumId,
    required int ticketTypeId,
    required DateTime visitDate,
    required double pricePaid,
    required String paymentMethod,
  }) async {
    final visitDateStr =
        '${visitDate.year.toString().padLeft(4, '0')}-${visitDate.month.toString().padLeft(2, '0')}-${visitDate.day.toString().padLeft(2, '0')}';

    // We let Supabase generate the UUID, then read it back to use as the QR payload.
    final inserted = await supabase
        .from('tickets')
        .insert({
          'visitor_id': visitorId,
          'museum_id': museumId,
          'ticket_type_id': ticketTypeId,
          'visit_date': visitDateStr,
          'status': 'aktif',
          'qr_payload': 'pending', // placeholder, updated immediately below
          'price_paid': pricePaid,
        })
        .select()
        .single();

    final ticketId = inserted['id'] as String;
    final qrPayload = 'ticket-$ticketId';

    // Now fill in the QR payload with the canonical format.
    final updated = await supabase
        .from('tickets')
        .update({'qr_payload': qrPayload})
        .eq('id', ticketId)
        .select('*, ticket_types(name), museums(name)')
        .single();

    await AppLogger.log('ticket.purchase', metadata: {
      'ticket_id': ticketId,
      'price': pricePaid,
      'payment_method': paymentMethod,
    });

    return Ticket.fromMap(updated);
  }

  Future<List<Ticket>> fetchMyTickets(String visitorId) async {
    final data = await supabase
        .from('tickets')
        .select('*, ticket_types(name), museums(name)')
        .eq('visitor_id', visitorId)
        .order('created_at', ascending: false);
    return (data as List)
        .map((t) => Ticket.fromMap(t as Map<String, dynamic>))
        .toList();
  }

  Future<Ticket?> fetchByQrPayload(String qrPayload) async {
    final data = await supabase
        .from('tickets')
        .select('*, ticket_types(name), museums(name)')
        .eq('qr_payload', qrPayload)
        .maybeSingle();
    if (data == null) return null;
    return Ticket.fromMap(data);
  }
}
