import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'visit_service.dart';

class TicketScanScreen extends StatefulWidget {
  const TicketScanScreen({super.key});

  @override
  State<TicketScanScreen> createState() => _TicketScanScreenState();
}

class _TicketScanScreenState extends State<TicketScanScreen> {
  final _service = VisitService();
  final _controller = MobileScannerController();
  bool _busy = false;
  _ScanOutcome? _outcome;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy || _outcome != null) return;
    final raw = capture.barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;

    setState(() => _busy = true);

    // QR payload format: "ticket-<uuid>"  ->  extract the uuid
    if (!raw.startsWith('ticket-')) {
      setState(() {
        _outcome = _ScanOutcome.error(
            title: 'Geçersiz QR', message: 'Bu bir bilet QR\'ı değil.');
        _busy = false;
      });
      return;
    }
    final ticketId = raw.substring('ticket-'.length);

    try {
      final result = await _service.processScan(ticketId);
      setState(() {
        _outcome = _ScanOutcome.success(
          title: result == ScanResult.entered
              ? 'GİRİŞ ONAYLANDI'
              : 'ÇIKIŞ KAYDEDİLDİ',
          message: result == ScanResult.entered
              ? 'Ziyaretçi müzeye giriş yaptı.'
              : 'Ziyaretçinin çıkışı kaydedildi.',
          entered: result == ScanResult.entered,
        );
        _busy = false;
      });
    } on VisitScanException catch (e) {
      setState(() {
        _outcome = _ScanOutcome.error(title: 'Hata', message: e.message);
        _busy = false;
      });
    }
  }

  void _resume() {
    setState(() => _outcome = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bilet Tara'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/staff'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          // overlay frame
          IgnorePointer(
            child: Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          // bottom hint
          if (_outcome == null)
            const Positioned(
              left: 16,
              right: 16,
              bottom: 32,
              child: Card(
                color: Colors.black54,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Ziyaretçinin bilet QR kodunu çerçeve içine getirin.\n'
                    'Aynı bilet yeniden tarandığında çıkış olarak kaydedilir.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ),
            ),
          if (_outcome != null) _OutcomePanel(outcome: _outcome!, onClose: _resume),
        ],
      ),
    );
  }
}

class _ScanOutcome {
  final String title;
  final String message;
  final bool success;
  final bool entered; // true=entry, false=exit (only when success)

  const _ScanOutcome({
    required this.title,
    required this.message,
    required this.success,
    this.entered = false,
  });

  factory _ScanOutcome.success({
    required String title,
    required String message,
    required bool entered,
  }) =>
      _ScanOutcome(
          title: title, message: message, success: true, entered: entered);

  factory _ScanOutcome.error({
    required String title,
    required String message,
  }) =>
      _ScanOutcome(title: title, message: message, success: false);
}

class _OutcomePanel extends StatelessWidget {
  const _OutcomePanel({required this.outcome, required this.onClose});
  final _ScanOutcome outcome;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final color = outcome.success
        ? (outcome.entered ? Colors.green.shade700 : Colors.blue.shade700)
        : Colors.red.shade700;
    final icon = outcome.success
        ? (outcome.entered ? Icons.login : Icons.logout)
        : Icons.error;
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        alignment: Alignment.center,
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 56),
                const SizedBox(height: 12),
                Text(outcome.title,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: color)),
                const SizedBox(height: 8),
                Text(outcome.message, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onClose,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: color),
                    child: const Text('Tekrar Tara'),
                  ),
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => GoRouter.of(context).go('/staff'),
                  child: const Text('Panele Dön'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

