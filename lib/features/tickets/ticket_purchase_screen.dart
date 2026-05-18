import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../auth/auth_state.dart';
import '../museums/museum_model.dart';
import '../museums/museum_service.dart';
import 'ticket_model.dart';
import 'ticket_qr_card.dart';
import 'ticket_service.dart';
import 'ticket_type_model.dart';

class TicketPurchaseScreen extends StatefulWidget {
  const TicketPurchaseScreen({super.key});

  @override
  State<TicketPurchaseScreen> createState() => _TicketPurchaseScreenState();
}

class _TicketPurchaseScreenState extends State<TicketPurchaseScreen> {
  final _ticketService = TicketService();
  final _museumService = MuseumService();

  List<TicketType>? _types;
  Museum? _museum;
  TicketType? _selectedType;
  DateTime _visitDate = DateTime.now();
  String _paymentMethod = 'Kart';

  bool _loadingInitial = true;
  bool _submitting = false;
  Ticket? _purchasedTicket;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    try {
      final types = await _ticketService.fetchTypes();
      final museums = await _museumService.fetchAll();
      if (!mounted) return;
      setState(() {
        _types = types;
        _museum = museums.isNotEmpty ? museums.first : null;
        _selectedType = types.isNotEmpty ? types.first : null;
        _loadingInitial = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loadingInitial = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null) {
      setState(() => _visitDate = picked);
    }
  }

  Future<void> _confirm() async {
    final type = _selectedType;
    final museum = _museum;
    final auth = context.read<AuthState>();
    final userId = auth.user?.id;
    if (type == null || museum == null || userId == null) return;

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final ticket = await _ticketService.purchase(
        visitorId: userId,
        museumId: museum.id,
        ticketTypeId: type.id,
        visitDate: _visitDate,
        pricePaid: type.price,
        paymentMethod: _paymentMethod,
      );
      if (!mounted) return;
      setState(() {
        _purchasedTicket = ticket;
        _submitting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Bilet alınamadı: $e';
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bilet Al'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              _purchasedTicket == null ? context.go('/home') : context.go('/tickets'),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loadingInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_purchasedTicket != null) return _buildSuccess(_purchasedTicket!);

    final fmt = DateFormat('dd MMM yyyy EEEE', 'tr_TR');
    final type = _selectedType;
    final museum = _museum;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (museum != null)
            Card(
              child: ListTile(
                leading:
                    const Icon(Icons.museum, color: AppTheme.primary),
                title: Text(museum.name,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(museum.city ?? ''),
              ),
            ),
          const SizedBox(height: 12),
          const Text('Bilet Tipi',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          RadioGroup<TicketType>(
            groupValue: _selectedType,
            onChanged: (v) => setState(() => _selectedType = v),
            child: Column(
              children: _types!
                  .map(
                    (t) => RadioListTile<TicketType>(
                      value: t,
                      title: Text(t.name),
                      subtitle: Text('₺${t.price.toStringAsFixed(2)}'),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Ziyaret Tarihi',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(fmt.format(_visitDate)),
              trailing: const Icon(Icons.edit_calendar),
              onTap: _pickDate,
            ),
          ),
          const SizedBox(height: 12),
          const Text('Ödeme Yöntemi',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Kart', 'Nakit', 'Muzekart']
                .map((m) => ChoiceChip(
                      label: Text(m),
                      selected: _paymentMethod == m,
                      onSelected: (_) =>
                          setState(() => _paymentMethod = m),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
          Card(
            color: AppTheme.primary.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Toplam',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  Text(
                    '₺${(type?.price ?? 0).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(_error!,
                  style: const TextStyle(color: Colors.redAccent)),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.confirmation_number),
              label: Text(_submitting ? 'İşleniyor...' : 'Ödemeyi Onayla'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _submitting ? null : _confirm,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bu bir simülasyondur. Gerçek bir ödeme alınmamaktadır.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(Ticket ticket) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        const Icon(Icons.check_circle, size: 64, color: Colors.green),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Biletiniz hazır!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Müzeye girişte bu QR kodu personele gösterin.',
            style: TextStyle(color: AppTheme.textMuted),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        TicketQrCard(ticket: ticket),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Ana Sayfa'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => context.go('/tickets'),
                child: const Text('Biletlerim'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
