import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/ride.dart';
import 'ride_image.dart';

class RideCard extends StatelessWidget {
  const RideCard({
    super.key,
    required this.ride,
    required this.waitTime,
    required this.onTap,
  });

  final Ride ride;
  final int waitTime;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: RideImage(
                imagePath: ride.image,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.08),
                    Colors.black.withOpacity(0.68),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Chip(label: Text(ride.type.toUpperCase())),
                  const Spacer(),
                  Text(
                    ride.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$waitTime mins wait • ${ride.duration} mins ride',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.1);
  }
}
