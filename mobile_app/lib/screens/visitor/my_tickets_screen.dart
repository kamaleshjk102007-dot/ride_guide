import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/ticket.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/ride_image.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  final api = ApiService();
  final sessionService = SessionService();
  final visitorController = TextEditingController();
  List<Ticket> tickets = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _prefillVisitor();
  }

  Future<void> _prefillVisitor() async {
    final session = await sessionService.loadSession();
    if (!mounted || session == null || session.userId.isEmpty) {
      return;
    }

    visitorController.text = session.userId;
    await loadTickets();
  }

  Future<void> loadTickets() async {
    if (visitorController.text.trim().isEmpty) {
      return;
    }
    setState(() => loading = true);
    try {
      final data = await api.getTickets(visitorController.text.trim());
      if (!mounted) {
        return;
      }
      setState(() {
        tickets = data;
      });
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Tickets')),
      body: GradientBackground(
        child: RefreshIndicator(
          onRefresh: loadTickets,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generate visitor tickets',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter a visitor ID or use your saved login to load beautifully formatted ride passes.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: visitorController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Visitor ID',
                        hintText: 'Visitor MongoDB ID',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: loading ? null : loadTickets,
                        icon: const Icon(Icons.confirmation_number_rounded),
                        label: Text(loading ? 'Loading...' : 'Generate tickets'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (tickets.isEmpty)
                GlassPanel(
                  child: Column(
                    children: [
                      const Icon(Icons.local_activity_outlined, size: 48, color: AppTheme.coral),
                      const SizedBox(height: 12),
                      Text(
                        'No tickets yet',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Book a ride first, then your generated passes will appear here.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ...tickets.map(
                  (ticket) => Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: _TicketPass(ticket: ticket),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketPass extends StatelessWidget {
  const _TicketPass({required this.ticket});

  final Ticket ticket;

  DateTime? get _bookingDate {
    try {
      return DateTime.parse(ticket.bookingDate);
    } catch (_) {
      return null;
    }
  }

  String _formatDate(DateTime value) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[value.month - 1]} ${value.day.toString().padLeft(2, '0')}, ${value.year}';
  }

  String _formatTime(DateTime value) {
    final hour = value.hour == 0 ? 12 : (value.hour > 12 ? value.hour - 12 : value.hour);
    final period = value.hour >= 12 ? 'PM' : 'AM';
    final minute = value.minute.toString().padLeft(2, '0');
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final bookingDate = _bookingDate;
    final dateLabel = bookingDate != null ? _formatDate(bookingDate) : 'Date unavailable';
    final timeLabel = bookingDate != null ? _formatTime(bookingDate) : '--:--';
    final ticketNo = ticket.id.length > 6 ? ticket.id.substring(ticket.id.length - 6).toUpperCase() : ticket.id.toUpperCase();
    final statusColor = ticket.status == 'Booked'
        ? const Color(0xFF1B8E5A)
        : ticket.status == 'Used'
            ? AppTheme.aqua
            : AppTheme.coral;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFFFDFEFF), Color(0xFFF3F8FF), Color(0xFFFDFEFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF78A9FF).withOpacity(0.18),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            Positioned(
              top: -22,
              left: -22,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF5EA8FF).withOpacity(0.36),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 24,
              top: 0,
              bottom: 0,
              child: Container(
                width: 2,
                decoration: BoxDecoration(
                  color: const Color(0xFFD0DDF4),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.celebration_rounded, color: Color(0xFF4F86D9), size: 34),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'ENTRY TICKET',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: const Color(0xFF3872C7),
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.8,
                              ),
                        ),
                      ),
                      Text(
                        'INR ${ticket.price.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: const Color(0xFF214E96),
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFDCE7F8)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_available_rounded, color: Color(0xFF3872C7), size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            dateLabel,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: const Color(0xFF3872C7),
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            ticket.status,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(color: Color(0xFFDCE7F8), height: 1),
                            const SizedBox(height: 16),
                            Text(
                              'ENTER TIME',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              timeLabel,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: const Color(0xFF214E96),
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 14),
                            const Divider(color: Color(0xFFDCE7F8), height: 1),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 94,
                                  height: 94,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: const Color(0xFFDCE7F8)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: QrImageView(
                                      data: ticket.qrCodeData,
                                      version: QrVersions.auto,
                                      eyeStyle: const QrEyeStyle(
                                        color: Color(0xFF1E1E1E),
                                        eyeShape: QrEyeShape.square,
                                      ),
                                      dataModuleStyle: const QrDataModuleStyle(
                                        color: Color(0xFF1E1E1E),
                                        dataModuleShape: QrDataModuleShape.square,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ticket.rideName,
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              color: const Color(0xFF3872C7),
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Ticket No: $ticketNo',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: const Color(0xFF214E96),
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          _MetaChip(label: ticket.rideType.isEmpty ? 'Ride pass' : ticket.rideType),
                                          _MetaChip(label: '${ticket.rideDuration} mins'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 220),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: const Color(0xFFEAF2FF),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                RideImage(
                                  imagePath: ticket.rideImage,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.35),
                                        const Color(0xFF3A76C8).withOpacity(0.18),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Non-transferable • No refunds • Valid only for the booked ride window',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: const Color(0xFF2D5EA8),
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
