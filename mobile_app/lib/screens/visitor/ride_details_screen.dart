import 'package:flutter/material.dart';

import '../../models/ride.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/ride_image.dart';
import 'booking_screen.dart';

class RideDetailsScreen extends StatelessWidget {
  const RideDetailsScreen({super.key, required this.ride});

  final Ride ride;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RideImage(
                  imagePath: ride.image,
                  height: 280,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: GlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ride.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      Text(ride.description),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          Chip(label: Text(ride.type)),
                          Chip(label: Text('Min age ${ride.minAge}+')),
                          Chip(label: Text('Capacity ${ride.capacity}')),
                          Chip(label: Text('${ride.duration} mins')),
                          Chip(label: Text(ride.status)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: ride.status == 'Active'
                              ? () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => BookingScreen(ride: ride)),
                                  )
                              : null,
                          child: const Text('Book this ride'),
                        ),
                      ),
                    ],
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
