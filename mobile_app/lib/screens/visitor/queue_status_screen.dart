import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/ride.dart';
import '../../services/api_service.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/ride_image.dart';
import 'ride_details_screen.dart';

class QueueStatusScreen extends StatefulWidget {
  const QueueStatusScreen({
    super.key,
    this.isAdmin = false,
  });

  final bool isAdmin;

  @override
  State<QueueStatusScreen> createState() => _QueueStatusScreenState();
}

class _QueueStatusScreenState extends State<QueueStatusScreen> {
  final api = ApiService();
  List<dynamic> queue = [];
  Timer? refreshTimer;
  bool loading = true;

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
    if (!mounted) {
      return;
    }
    setState(() {
      queue = data;
      loading = false;
    });
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
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFEFE7), Color(0xFFEAFBFF)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Queue Monitor',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Track queue lengths, spot slower attractions, and tap a ride for full details.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.05),
              const SizedBox(height: 16),
              if (loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                ...queue.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: GestureDetector(
                      onTap: () => widget.isAdmin ? _openQueueEditor(item) : _openRideDetails(item),
                      child: GlassPanel(
                        padding: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                              child: RideImage(
                                imagePath: item.rideImage,
                                height: 150,
                                width: double.infinity,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.rideName,
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      _waitBadge(item.currentWaitTime),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      _queueInfoPill(Icons.people_alt_rounded, '${item.peopleInQueue} in line'),
                                      _queueInfoPill(Icons.schedule_rounded, '${item.duration} mins ride'),
                                      _queueInfoPill(Icons.event_seat_rounded, 'Cap ${item.capacity}'),
                                      _queueInfoPill(Icons.flag_rounded, item.status),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                      Row(
                                        children: [
                                          _queueSignalChip(
                                            label: item.currentWaitTime <= 8
                                                ? 'Fast access'
                                            : item.currentWaitTime <= 15
                                                ? 'Moderate line'
                                                : 'Peak line',
                                        color: item.currentWaitTime <= 8
                                            ? const Color(0xFFE8F9EC)
                                            : item.currentWaitTime <= 15
                                                ? const Color(0xFFFFF4DD)
                                                : const Color(0xFFFFECE7),
                                          ),
                                          if (widget.isAdmin) ...[
                                            const SizedBox(width: 10),
                                            _queueSignalChip(
                                              label: 'Edit queue',
                                              color: const Color(0xFFEAF3FF),
                                            ),
                                          ],
                                          const Spacer(),
                                          Text(
                                            widget.isAdmin ? 'Tap to edit' : 'Tap for details',
                                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ],
                                      ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn().slideX(begin: 0.05),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openRideDetails(dynamic item) {
    final ride = Ride(
      id: item.rideId,
      name: item.rideName,
      type: item.rideType,
      description: '${item.rideName} is currently running with a live queue.',
      image: item.rideImage,
      minAge: 0,
      capacity: item.capacity,
      duration: item.duration,
      status: item.status,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RideDetailsScreen(ride: ride)),
    );
  }

  Future<void> _openQueueEditor(dynamic item) async {
    final peopleController = TextEditingController(text: item.peopleInQueue.toString());
    var selectedStatus = item.status;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FCFF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 56,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Edit Queue',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.rideName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: peopleController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'People in queue'),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedStatus,
                          decoration: const InputDecoration(labelText: 'Ride status'),
                          items: const [
                            DropdownMenuItem(value: 'Active', child: Text('Active')),
                            DropdownMenuItem(value: 'Maintenance', child: Text('Maintenance')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() => selectedStatus = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF7FF),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            'Wait time is estimated automatically from queue size and ride capacity.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final nextPeople = int.tryParse(peopleController.text.trim()) ?? item.peopleInQueue;
                              await api.updateQueue(
                                rideId: item.rideId,
                                peopleInQueue: nextPeople,
                              );
                              await api.updateRide(
                                rideId: item.rideId,
                                payload: {
                                  'ride_name': item.rideName,
                                  'type': item.rideType,
                                  'description': '${item.rideName} is currently running with a live queue.',
                                  'image': item.rideImage,
                                  'min_age': 0,
                                  'capacity': item.capacity,
                                  'duration': item.duration,
                                  'status': selectedStatus,
                                },
                              );
                              if (!mounted) {
                                return;
                              }
                              Navigator.pop(context);
                              await loadQueue();
                              if (!mounted) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Queue updated successfully.')),
                              );
                            },
                            child: const Text('Save Queue Changes'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _waitBadge(int waitTime) {
    final Color bgColor;
    final Color fgColor;

    if (waitTime <= 8) {
      bgColor = const Color(0xFFE8F9EC);
      fgColor = const Color(0xFF2E8B57);
    } else if (waitTime <= 15) {
      bgColor = const Color(0xFFFFF4DD);
      fgColor = const Color(0xFFB7791F);
    } else {
      bgColor = const Color(0xFFFFECE7);
      fgColor = const Color(0xFFCC5A3D);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$waitTime mins',
        style: TextStyle(color: fgColor, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _queueInfoPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }

  Widget _queueSignalChip({
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
