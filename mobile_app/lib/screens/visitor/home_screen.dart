import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/ride_image.dart';
import '../../widgets/stat_card.dart';
import 'feedback_screen.dart';
import 'payment_screen.dart';
import 'profile_screen.dart';
import 'ride_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final api = ApiService();
  Map<String, dynamic>? stats;
  List<dynamic> rides = [];

  static const List<_HighlightChipData> _highlightChips = [
    _HighlightChipData(label: 'Live queues', icon: Icons.graphic_eq_rounded),
    _HighlightChipData(label: 'Fast booking', icon: Icons.flash_on_rounded),
    _HighlightChipData(label: 'Park map', icon: Icons.explore_rounded),
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final analytics = await api.getAnalytics();
    final rideData = await api.getRides();
    setState(() {
      stats = analytics;
      rides = rideData;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cards = stats?['cards'] as Map<String, dynamic>?;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(22, 22, 18, 22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.9),
                      const Color(0xFFFFF8EF).withOpacity(0.92),
                      const Color(0xFFEFFBFF).withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.coral.withOpacity(0.08),
                      blurRadius: 28,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.coral.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'Wonder Park',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        color: AppTheme.coral,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.08),
                              const SizedBox(height: 16),
                              Text(
                                'Hello, park explorer',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                              ).animate().fadeIn(duration: 350.ms).slideX(begin: -0.04),
                              const SizedBox(height: 8),
                              Text(
                                'Book faster, monitor queues live, and discover what is trending today.',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45),
                              ).animate().fadeIn(delay: 100.ms),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProfileScreen()),
                          ),
                          borderRadius: BorderRadius.circular(22),
                          child: Container(
                            width: 62,
                            height: 62,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                )
                              ],
                            ),
                            child: const Icon(Icons.settings_rounded, size: 30, color: AppTheme.navy),
                          ),
                        ).animate().fadeIn(delay: 140.ms).scale(begin: const Offset(0.92, 0.92)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _highlightChips
                            .map(
                              (chip) => Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: _HighlightChip(chip: chip),
                              ),
                            )
                            .toList(),
                      ),
                    ).animate().fadeIn(delay: 160.ms).slideY(begin: 0.08),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GlassPanel(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    StatCard(
                      title: 'Visitors',
                      value: '${cards?['totalVisitors'] ?? 0}',
                      color: AppTheme.coral,
                      icon: Icons.groups_rounded,
                    ),
                    StatCard(
                      title: 'Rides',
                      value: '${cards?['totalRides'] ?? 0}',
                      color: AppTheme.aqua,
                      icon: Icons.attractions_rounded,
                    ),
                    StatCard(
                      title: 'Tickets',
                      value: '${cards?['activeTickets'] ?? 0}',
                      color: AppTheme.yellow,
                      icon: Icons.confirmation_number_rounded,
                    ),
                    StatCard(
                      title: 'Avg Rating',
                      value: '${cards?['averageRating'] ?? 0}',
                      color: Colors.purple,
                      icon: Icons.star_rounded,
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.08),
              const SizedBox(height: 20),
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Quick actions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.navy.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '2 shortcuts',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppTheme.navy,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const PaymentScreen()),
                            ),
                            icon: const Icon(Icons.payment_rounded),
                            label: const Text('Payment'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const FeedbackScreen()),
                            ),
                            icon: const Icon(Icons.reviews_rounded),
                            label: const Text('Feedback'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 140.ms).slideY(begin: 0.06),
              const SizedBox(height: 20),
              Text(
                'Featured rides',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ...rides.take(3).map(
                    (ride) {
                      final int rideIndex = rides.indexOf(ride);
                      final List<Color> accentColors = [
                        AppTheme.coral,
                        AppTheme.aqua,
                        AppTheme.yellow,
                      ];

                      return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RideDetailsScreen(ride: ride)),
                        ),
                        child: GlassPanel(
                          padding: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                                    child: RideImage(
                                      imagePath: ride.image,
                                      height: 200,
                                      width: double.infinity,
                                    ),
                                  ),
                                  Positioned(
                                    left: 16,
                                    top: 16,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.88),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.local_fire_department_rounded,
                                            color: accentColors[rideIndex % accentColors.length],
                                            size: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Popular',
                                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(ride.name, style: Theme.of(context).textTheme.titleLarge),
                                    const SizedBox(height: 8),
                                    Text(ride.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        _RideMetaPill(
                                          icon: Icons.schedule_rounded,
                                          label: '${ride.duration} mins',
                                        ),
                                        const SizedBox(width: 10),
                                        _RideMetaPill(
                                          icon: Icons.people_alt_rounded,
                                          label: '${ride.capacity} seats',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: (180 + (rideIndex * 80)).ms).slideY(begin: 0.08),
                    );
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HighlightChipData {
  const _HighlightChipData({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class _HighlightChip extends StatelessWidget {
  const _HighlightChip({required this.chip});

  final _HighlightChipData chip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(chip.icon, size: 18, color: AppTheme.navy),
          const SizedBox(width: 8),
          Text(
            chip.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _RideMetaPill extends StatelessWidget {
  const _RideMetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.navy.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.navy),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.navy,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
