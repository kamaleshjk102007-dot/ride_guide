import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/ride.dart';
import '../../services/api_service.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/ride_card.dart';
import 'ride_details_screen.dart';

class RideListScreen extends StatefulWidget {
  const RideListScreen({super.key});

  @override
  State<RideListScreen> createState() => _RideListScreenState();
}

class _RideListScreenState extends State<RideListScreen> {
  final api = ApiService();
  List<Ride> rides = [];
  List<dynamic> queue = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final results = await Future.wait([
      api.getRides(),
      api.getQueue(),
    ]);
    final rideData = results[0] as List<Ride>;
    final queueData = results[1] as List<dynamic>;
    const priorityOrder = [
      'Roller Coaster',
      'Ferris Wheel',
      'Bumper Cars',
      'Drop Tower',
      'Water Splash Ride',
      'Carousel (Merry-Go-Round)',
    ];

    rideData.sort((a, b) {
      final aIndex = priorityOrder.indexOf(a.name);
      final bIndex = priorityOrder.indexOf(b.name);
      final safeA = aIndex == -1 ? 999 : aIndex;
      final safeB = bIndex == -1 ? 999 : bIndex;
      return safeA.compareTo(safeB);
    });

    if (!mounted) {
      return;
    }
    setState(() {
      rides = rideData;
      queue = queueData;
      loading = false;
    });
  }

  int waitForRide(String rideName) {
    for (final item in queue) {
      if (item.rideName == rideName) {
        return item.currentWaitTime;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ride List')),
      body: GradientBackground(
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
                    'Ride Explorer',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Featured lineup: Roller Coaster, Ferris Wheel, Bumper Cars, Drop Tower, Water Splash Ride, and Carousel.',
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
              ...rides.map(
                (ride) => SizedBox(
                  height: 240,
                  child: RideCard(
                    ride: ride,
                    waitTime: waitForRide(ride.name),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RideDetailsScreen(ride: ride)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
