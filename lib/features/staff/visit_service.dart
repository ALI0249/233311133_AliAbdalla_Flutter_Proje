import '../../core/logger.dart';
import '../../core/supabase_client.dart';

enum ScanResult { entered, exited }

class VisitScanException implements Exception {
  final String code;
  final String message;
  const VisitScanException(this.code, this.message);
  @override
  String toString() => message;
}

class VisitService {
  /// Calls the `process_ticket_scan` RPC which atomically:
  ///  - inserts a visit row and marks the ticket as used (ENTRY), or
  ///  - stamps exited_at on the open visit (EXIT)
  Future<ScanResult> processScan(String ticketId) async {
    try {
      final result = await supabase.rpc(
        'process_ticket_scan',
        params: {'p_ticket_id': ticketId},
      );
      await AppLogger.log('ticket.scan', metadata: {
        'ticket_id': ticketId,
        'result': result,
      });
      if (result == 'entered') return ScanResult.entered;
      if (result == 'exited') return ScanResult.exited;
      throw VisitScanException('UNKNOWN', 'Beklenmeyen sonuç: $result');
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('BILET_BULUNAMADI')) {
        throw const VisitScanException(
            'BILET_BULUNAMADI', 'Bilet bulunamadı.');
      }
      if (msg.contains('BILET_IPTAL')) {
        throw const VisitScanException(
            'BILET_IPTAL', 'Bu bilet iptal edilmiş.');
      }
      if (msg.contains('BILET_BUGUN_DEGIL')) {
        throw const VisitScanException(
            'BILET_BUGUN_DEGIL', 'Biletin ziyaret tarihi bugün değil.');
      }
      if (msg.contains('YETKI_YOK')) {
        throw const VisitScanException('YETKI_YOK', 'Yetkiniz yok.');
      }
      throw VisitScanException('UNKNOWN', msg);
    }
  }
}
