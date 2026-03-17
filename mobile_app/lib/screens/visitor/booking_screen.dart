import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/ride.dart';
import '../../services/api_service.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/gradient_background.dart';
import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.ride});

  final Ride ride;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final api = ApiService();
  final visitorIdController = TextEditingController();
  final priceController = TextEditingController(text: '450');
  String qrPayload = '';
  String createdTicketId = '';

  Future<void> _bookTicket() async {
    final response = await api.bookTicket(
      visitorId: visitorIdController.text.trim(),
      rideId: widget.ride.id,
      price: double.parse(priceController.text.trim()),
    );

    setState(() {
      qrPayload = 'Ticket:${response['ticket']?['_id'] ?? ''}|Ride:${widget.ride.name}|Visitor:${visitorIdController.text.trim()}';
      createdTicketId = response['ticket']?['_id'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book ${widget.ride.name}')),
      body: GradientBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Create ride ticket', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  TextField(controller: visitorIdController, decoration: const InputDecoration(labelText: 'Visitor ID')),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Ticket Price'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _bookTicket,
                      child: const Text('Generate QR ticket'),
                    ),
                  ),
                ],
              ),
            ),
            if (qrPayload.isNotEmpty) ...[
              const SizedBox(height: 18),
              GlassPanel(
                child: Column(
                  children: [
                    Text('QR Ride Ticket', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    QrImageView(data: qrPayload, size: 220),
                    const SizedBox(height: 16),
                    Text(widget.ride.name),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(
                            ticketId: createdTicketId,
                            visitorId: visitorIdController.text.trim(),
                            amount: double.tryParse(priceController.text.trim()) ?? 0,
                          ),
                        ),
                      ),
                      child: const Text('Proceed to payment'),
                    )
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
