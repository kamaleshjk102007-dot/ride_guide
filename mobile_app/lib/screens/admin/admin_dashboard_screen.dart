import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/stat_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final api = ApiService();
  Map<String, dynamic>? analytics;
  List<dynamic> staff = [];
  List<dynamic> maintenance = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final dashboard = await api.getAnalytics();
    final staffData = await api.getStaff();
    final maintenanceData = await api.getMaintenance();
    setState(() {
      analytics = dashboard;
      staff = staffData;
      maintenance = maintenanceData;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cards = analytics?['cards'] as Map<String, dynamic>? ?? {};
    final queueLoad = analytics?['queueLoad'] as List<dynamic>? ?? [];

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B57), Color(0xFFFFA95C), Color(0xFF00A8A8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.coral.withOpacity(0.22),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shield_rounded, color: Colors.white, size: 28),
                        ),
                        const Spacer(),
                        _ActionChip(
                          icon: Icons.person_outline_rounded,
                          label: 'Profile',
                          onTap: () => _showProfileSheet(context),
                        ),
                        const SizedBox(width: 10),
                        _ActionChip(
                          icon: Icons.logout_rounded,
                          label: 'Logout',
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Admin Dashboard',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Monitor revenue, staff rhythm, queue pressure, and maintenance from one bright control center.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withOpacity(0.92)),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _HeroStat(
                            title: 'Live queue',
                            value: '${queueLoad.length} rides tracked',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _HeroStat(
                            title: 'Guest rating',
                            value: '${cards['averageRating'] ?? 0} / 5',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.06),
              const SizedBox(height: 18),
              Text(
                'Operations overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(width: 160, child: StatCard(title: 'Revenue', value: 'INR ${cards['revenue'] ?? 0}', color: AppTheme.coral)),
                  SizedBox(width: 160, child: StatCard(title: 'Visitors', value: '${cards['totalVisitors'] ?? 0}', color: AppTheme.aqua)),
                  SizedBox(width: 160, child: StatCard(title: 'Rides', value: '${cards['totalRides'] ?? 0}', color: AppTheme.yellow)),
                  SizedBox(width: 160, child: StatCard(title: 'Rating', value: '${cards['averageRating'] ?? 0}', color: Colors.purple)),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _miniInsightCard(
                      context,
                      icon: Icons.attach_money_rounded,
                      title: 'Revenue pulse',
                      subtitle: 'Fast view of park earnings today',
                      color: const Color(0xFFFFEEE6),
                    ),
                    _miniInsightCard(
                      context,
                      icon: Icons.groups_2_rounded,
                      title: 'Guest flow',
                      subtitle: '${cards['totalVisitors'] ?? 0} visitor profiles in system',
                      color: const Color(0xFFE7FBFB),
                    ),
                    _miniInsightCard(
                      context,
                      icon: Icons.engineering_rounded,
                      title: 'Maintenance',
                      subtitle: '${maintenance.length} records being tracked',
                      color: const Color(0xFFFFF5DD),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Staff management snapshot', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    ...staff.map(
                      (member) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7FAFF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFFFEEE6),
                            child: Icon(Icons.badge_outlined, color: AppTheme.coral),
                          ),
                          title: Text(member['name'] ?? ''),
                          subtitle: Text('${member['role']} • ${member['shift']}'),
                          trailing: Text(member['assigned_ride']?['ride_name'] ?? 'Unassigned'),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 18),
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Maintenance board', style: Theme.of(context).textTheme.titleLarge),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEEE6),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text('${maintenance.length} active logs'),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...maintenance.map(
                      (record) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFEDEDED)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7FBFB),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.build_circle_outlined, color: AppTheme.aqua),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(record['ride_id']?['ride_name'] ?? 'Ride'),
                                  const SizedBox(height: 4),
                                  Text(record['notes'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF5DD),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(record['status'] ?? ''),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniInsightCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.navy),
          const SizedBox(height: 10),
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  void _showProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFFF9FCFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 18),
            const CircleAvatar(
              radius: 34,
              backgroundColor: Color(0xFFFFEEE6),
              child: Icon(Icons.admin_panel_settings_rounded, color: AppTheme.coral, size: 34),
            ),
            const SizedBox(height: 12),
            Text('Park Admin', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('admin@wonderpark.com'),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              tileColor: Colors.white,
              leading: const Icon(Icons.verified_user_outlined),
              title: const Text('Role'),
              subtitle: const Text('Operations Administrator'),
            ),
            const SizedBox(height: 10),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              tileColor: Colors.white,
              leading: const Icon(Icons.power_settings_new_rounded, color: Colors.redAccent),
              title: const Text('Logout'),
              subtitle: const Text('Return to the login screen'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
