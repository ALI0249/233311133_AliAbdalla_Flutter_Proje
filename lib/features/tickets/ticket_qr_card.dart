import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme.dart';
import 'ticket_model.dart';

class TicketQrCard extends StatelessWidget {
  const TicketQrCard({super.key, required this.ticket});
  final Ticket ticket;

  Color _statusColor() {
    if (ticket.isUsed) return AppTheme.textMuted;
    if (ticket.isCancelled) return Colors.redAccent;
    return Colors.green.shade700;
  }

  String _statusLabel() {
    if (ticket.isUsed) return 'KULLANILDI';
    if (ticket.isCancelled) return 'İPTAL';
    return 'AKTİF';
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy', 'tr_TR');
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.museum, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ticket.museumName ?? 'Müze',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor().withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _statusLabel(),
                    style: TextStyle(
                      color: _statusColor(),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            QrImageView(
              data: ticket.qrPayload,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppTheme.primary,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _info('Ziyaret Tarihi', fmt.format(ticket.visitDate)),
                _info('Tip', ticket.ticketTypeName ?? '-'),
                _info('Fiyat', '₺${ticket.pricePaid.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(
              ticket.qrPayload,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textMuted,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppTheme.textMuted)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
