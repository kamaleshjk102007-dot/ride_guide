import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/gradient_background.dart';

class RideManagementScreen extends StatefulWidget {
  const RideManagementScreen({super.key});

  @override
  State<RideManagementScreen> createState() => _RideManagementScreenState();
}

class _RideManagementScreenState extends State<RideManagementScreen> {
  final api = ApiService();
  List<dynamic> rides = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await api.getRides();
    setState(() => rides = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ride Management')),
      body: GradientBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rides inventory', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ...rides.map((ride) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(ride.image, width: 52, height: 52, fit: BoxFit.cover),
                        ),
                        title: Text(ride.name),
                        subtitle: Text('${ride.type} • capacity ${ride.capacity} • ${ride.duration} mins'),
                        trailing: Text(ride.status),
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
