import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/ticket.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
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

  List<Ticket> tickets = [];
  bool loading = false;
  String visitorId = '';
  String visitorName = 'Park Guest';

  @override
  void initState() {
    super.initState();
    _prefillVisitor();
  }

  Future<void> _prefillVisitor() async {
    final savedTicketVisitorId = await sessionService.loadTicketVisitorId();
    final session = await sessionService.loadSession();
    final preferredVisitorId = (session?.visitorId.isNotEmpty ?? false)
        ? session!.visitorId
        : (savedTicketVisitorId ?? '');

    if (!mounted) {
      return;
    }

    setState(() {
      visitorId = preferredVisitorId;
      visitorName = (session?.name.isNotEmpty ?? false) ? session!.name : visitorName;
    });
  }

  Future<void> loadTickets() async {
    if (visitorId.trim().isEmpty) {
      return;
    }

    setState(() => loading = true);
    try {
      final data = await api.getTickets(visitorId.trim());
      if (!mounted) {
        return;
      }

      setState(() {
        tickets = data.isEmpty ? [_buildEntryPass()] : data;
      });
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Ticket _buildEntryPass() {
    final now = DateTime.now();
    return Ticket(
      id: 'ENTRY-$visitorId',
      visitorId: visitorId,
      visitorName: visitorName,
      rideName: 'Park Entry Pass',
      bookingDate: now.toIso8601String(),
      price: 499,
      status: 'Booked',
      qrCodeData: 'entry-ticket:$visitorId:${now.toIso8601String()}',
      rideImage: 'assets/images/ferris_wheel.jpg',
      rideType: 'Entry',
      rideDuration: 1,
    );
  }

  String _formatDate(DateTime value) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
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
    return Scaffold(
      appBar: AppBar(title: const Text('My Tickets')),
      body: GradientBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.88),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My entry tickets',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your entry passes are linked automatically to the visitor ID assigned to your account.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7FB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Visitor ID',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.black54),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          visitorId.isEmpty ? 'Auto-generated visitor ID' : visitorId,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: loading ? null : loadTickets,
                      child: Text(loading ? 'Loading...' : 'Load tickets'),
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
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.local_activity_outlined, size: 52, color: AppTheme.coral),
                    const SizedBox(height: 12),
                    Text(
                      'No tickets yet',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Book a ride first, then your generated entry passes will appear here.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...tickets.map(
                (ticket) => Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: _TicketCard(
                    ticket: ticket,
                    formatDate: _formatDate,
                    formatTime: _formatTime,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.ticket,
    required this.formatDate,
    required this.formatTime,
  });

  final Ticket ticket;
  final String Function(DateTime) formatDate;
  final String Function(DateTime) formatTime;

  @override
  Widget build(BuildContext context) {
    final parsedDate = DateTime.tryParse(ticket.bookingDate) ?? DateTime.now();
    final ticketNo = ticket.id.length > 6 ? ticket.id.substring(ticket.id.length - 6).toUpperCase() : ticket.id.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFFFDFEFF), Color(0xFFF1F7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D9AE8).withOpacity(0.18),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF9FD0FF), Color(0xFF447FE7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(Icons.celebration_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'ENTRY TICKET',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: const Color(0xFF3872C7),
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                  Text(
                    '₹${ticket.price.toStringAsFixed(0)}.00',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF214E96),
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              compact
                  ? Column(
                      children: [
                        _TicketInfoBlock(
                          ticket: ticket,
                          dateLabel: formatDate(parsedDate),
                          timeLabel: formatTime(parsedDate),
                          ticketNo: ticketNo,
                        ),
                        const SizedBox(height: 16),
                        _TicketImageBlock(ticket: ticket),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _TicketInfoBlock(
                            ticket: ticket,
                            dateLabel: formatDate(parsedDate),
                            timeLabel: formatTime(parsedDate),
                            ticketNo: ticketNo,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: _TicketImageBlock(ticket: ticket),
                        ),
                      ],
                    ),
              const SizedBox(height: 14),
              Text(
                'Non-transferable • No refunds • Valid only on date of entry',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TicketInfoBlock extends StatelessWidget {
  const _TicketInfoBlock({
    required this.ticket,
    required this.dateLabel,
    required this.timeLabel,
    required this.ticketNo,
  });

  final Ticket ticket;
  final String dateLabel;
  final String timeLabel;
  final String ticketNo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.86),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD7E3F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFD7E3F7)),
          const SizedBox(height: 14),
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
          const Divider(color: Color(0xFFD7E3F7)),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFD7E3F7)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: QrImageView(data: ticket.qrCodeData, version: QrVersions.auto),
                  ),
                ),
              ),
              const SizedBox(width: 16),
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
                    const SizedBox(height: 6),
                    Text('Visitor ID: ${ticket.visitorId}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Ticket No: $ticketNo', style: const TextStyle(fontWeight: FontWeight.w700)),
                    if (ticket.visitorName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(ticket.visitorName),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TicketImageBlock extends StatelessWidget {
  const _TicketImageBlock({required this.ticket});

  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
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
                    Colors.white.withOpacity(0.28),
                    const Color(0xFF3A76C8).withOpacity(0.14),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
