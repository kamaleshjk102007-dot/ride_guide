import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/gradient_background.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final api = ApiService();
  final visitorController = TextEditingController();
  final rideController = TextEditingController();
  final commentController = TextEditingController();
  int rating = 5;

  Future<void> submit() async {
    await api.submitFeedback(
      visitorId: visitorController.text.trim(),
      rideId: rideController.text.trim(),
      rating: rating,
      comment: commentController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feedback submitted.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: GradientBackground(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: GlassPanel(
            child: Column(
              children: [
                TextField(controller: visitorController, decoration: const InputDecoration(labelText: 'Visitor ID')),
                const SizedBox(height: 12),
                TextField(controller: rideController, decoration: const InputDecoration(labelText: 'Ride ID')),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: rating,
                  items: [5, 4, 3, 2, 1]
                      .map((value) => DropdownMenuItem(value: value, child: Text('$value stars')))
                      .toList(),
                  onChanged: (value) => setState(() => rating = value ?? 5),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: commentController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Comment'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: submit,
                    child: const Text('Submit feedback'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
