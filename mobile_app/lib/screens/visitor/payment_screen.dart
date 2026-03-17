import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/gradient_background.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    this.ticketId = '',
    this.visitorId = '',
    this.amount = 0,
  });

  final String ticketId;
  final String visitorId;
  final double amount;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final api = ApiService();
  late final TextEditingController ticketController;
  late final TextEditingController visitorController;
  late final TextEditingController amountController;
  String paymentMethod = 'UPI';

  @override
  void initState() {
    super.initState();
    ticketController = TextEditingController(text: widget.ticketId);
    visitorController = TextEditingController(text: widget.visitorId);
    amountController = TextEditingController(text: widget.amount == 0 ? '0' : widget.amount.toStringAsFixed(0));
  }

  Future<void> _pay() async {
    await api.makePayment(
      ticketId: ticketController.text.trim(),
      visitorId: visitorController.text.trim(),
      amount: double.parse(amountController.text.trim()),
      paymentMethod: paymentMethod,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment recorded successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: GradientBackground(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: GlassPanel(
            child: Column(
              children: [
                TextField(controller: ticketController, decoration: const InputDecoration(labelText: 'Ticket ID')),
                const SizedBox(height: 12),
                TextField(controller: visitorController, decoration: const InputDecoration(labelText: 'Visitor ID')),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: paymentMethod,
                  items: const ['UPI', 'Card', 'Cash', 'Wallet']
                      .map((method) => DropdownMenuItem(value: method, child: Text(method)))
                      .toList(),
                  onChanged: (value) => setState(() => paymentMethod = value ?? 'UPI'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _pay,
                    child: const Text('Pay now'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
