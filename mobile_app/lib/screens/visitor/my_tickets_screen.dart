import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/gradient_background.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  final api = ApiService();
  final visitorController = TextEditingController();
  List<dynamic> tickets = [];
  bool loading = false;

  Future<void> loadTickets() async {
    if (visitorController.text.trim().isEmpty) {
      return;
    }
    setState(() => loading = true);
    final data = await api.getTickets(visitorController.text.trim());
    if (!mounted) {
      return;
    }
    setState(() {
      tickets = data;
      loading = false;
    });
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
                  children: [
                    TextField(
                      controller: visitorController,
                      decoration: const InputDecoration(labelText: 'Enter Visitor ID'),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loadTickets,
                        child: Text(loading ? 'Loading...' : 'Load booked tickets'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                ...tickets.map(
                  (ticket) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: GlassPanel(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(ticket.rideName),
                        subtitle: Text(ticket.bookingDate),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('INR ${ticket.price.toStringAsFixed(0)}'),
                            Text(ticket.status),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
