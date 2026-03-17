import 'package:flutter/material.dart';

import '../../models/ride.dart';
import '../../services/api_service.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/ride_image.dart';

class RideManagementScreen extends StatefulWidget {
  const RideManagementScreen({super.key});

  @override
  State<RideManagementScreen> createState() => _RideManagementScreenState();
}

class _RideManagementScreenState extends State<RideManagementScreen> {
  final api = ApiService();
  List<Ride> rides = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await api.getRides();
    if (!mounted) {
      return;
    }
    setState(() {
      rides = data;
      loading = false;
    });
  }

  Future<void> _editRide(Ride ride) async {
    final nameController = TextEditingController(text: ride.name);
    final minAgeController = TextEditingController(text: ride.minAge.toString());
    final capacityController = TextEditingController(text: ride.capacity.toString());
    final durationController = TextEditingController(text: ride.duration.toString());
    var selectedType = ride.type;
    var selectedStatus = ride.status;

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
                          'Edit Ride',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'Ride name'),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedType,
                          decoration: const InputDecoration(labelText: 'Type'),
                          items: const [
                            DropdownMenuItem(value: 'thrill', child: Text('thrill')),
                            DropdownMenuItem(value: 'family', child: Text('family')),
                            DropdownMenuItem(value: 'water', child: Text('water')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() => selectedType = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedStatus,
                          decoration: const InputDecoration(labelText: 'Status'),
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
                        TextField(
                          controller: minAgeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Minimum age'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: capacityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Capacity'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: durationController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Duration (mins)'),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              await api.updateRide(
                                rideId: ride.id,
                                payload: {
                                  'ride_name': nameController.text.trim(),
                                  'type': selectedType,
                                  'description': ride.description,
                                  'image': ride.image,
                                  'min_age': int.tryParse(minAgeController.text.trim()) ?? ride.minAge,
                                  'capacity': int.tryParse(capacityController.text.trim()) ?? ride.capacity,
                                  'duration': int.tryParse(durationController.text.trim()) ?? ride.duration,
                                  'status': selectedStatus,
                                },
                              );
                              if (!mounted) {
                                return;
                              }
                              Navigator.pop(context);
                              await loadData();
                              if (!mounted) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Ride updated successfully.')),
                              );
                            },
                            child: const Text('Save Changes'),
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
                  Row(
                    children: [
                      Text('Rides inventory', style: Theme.of(context).textTheme.titleLarge),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3EF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text('${rides.length} rides'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    ...rides.map(
                      (ride) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: RideImage(
                                imagePath: ride.image,
                                width: 62,
                                height: 62,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ride.name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('${ride.type} • capacity ${ride.capacity} • ${ride.duration} mins'),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: ride.status == 'Active'
                                          ? const Color(0xFFE9F9EE)
                                          : const Color(0xFFFFF3E8),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(ride.status),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _editRide(ride),
                              icon: const Icon(Icons.edit_rounded),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
