import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../services/api_service.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/gradient_background.dart';

class QueueStatusScreen extends StatefulWidget {
  const QueueStatusScreen({super.key});

  @override
  State<QueueStatusScreen> createState() => _QueueStatusScreenState();
}

class _QueueStatusScreenState extends State<QueueStatusScreen> {
  final api = ApiService();
  List<dynamic> queue = [];
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    loadQueue();
    refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) => loadQueue());
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> loadQueue() async {
    final data = await api.getQueue();
    setState(() => queue = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Queue Status')),
      body: GradientBackground(
        child: RefreshIndicator(
          onRefresh: loadQueue,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: queue
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: GlassPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.rideName, style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 10),
                          Text('People in queue: ${item.peopleInQueue}'),
                          Text('Estimated wait: ${item.currentWaitTime} mins'),
                          Text('Status: ${item.status}'),
                        ],
                      ),
                    ).animate().fadeIn().slideX(begin: 0.05),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
