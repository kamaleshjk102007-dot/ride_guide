import 'package:flutter/material.dart';

import 'admin/admin_dashboard_screen.dart';
import 'admin/analytics_screen.dart';
import 'admin/ride_management_screen.dart';
import 'visitor/home_screen.dart';
import 'visitor/my_tickets_screen.dart';
import 'visitor/park_map_screen.dart';
import 'visitor/queue_status_screen.dart';
import 'visitor/ride_list_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.role});

  static const routeName = '/home';
  final String role;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final visitorPages = [
      const HomeScreen(),
      const RideListScreen(),
      const MyTicketsScreen(),
      const QueueStatusScreen(),
      const ParkMapScreen(),
    ];

    final adminPages = [
      const AdminDashboardScreen(),
      const RideManagementScreen(),
      const AnalyticsScreen(),
      const QueueStatusScreen(),
      const ParkMapScreen(),
    ];

    final pages = widget.role == 'admin' ? adminPages : visitorPages;

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (value) => setState(() => currentIndex = value),
        items: widget.role == 'admin'
            ? const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
                BottomNavigationBarItem(icon: Icon(Icons.attractions), label: 'Rides'),
                BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Analytics'),
                BottomNavigationBarItem(icon: Icon(Icons.queue_play_next), label: 'Queue'),
                BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: 'Map'),
              ]
            : const [
                BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.attractions), label: 'Rides'),
                BottomNavigationBarItem(icon: Icon(Icons.confirmation_number), label: 'Tickets'),
                BottomNavigationBarItem(icon: Icon(Icons.queue_play_next), label: 'Queue'),
                BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: 'Map'),
              ],
      ),
    );
  }
}
