import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/app_theme.dart';
import '../../widgets/gradient_background.dart';

class ParkMapScreen extends StatefulWidget {
  const ParkMapScreen({super.key});

  @override
  State<ParkMapScreen> createState() => _ParkMapScreenState();
}

class _ParkMapScreenState extends State<ParkMapScreen> with SingleTickerProviderStateMixin {
  final TransformationController _controller = TransformationController();
  final Offset currentLocation = const Offset(225, 650);
  late final AnimationController _mapAnimationController;
  Animation<Matrix4>? _mapAnimation;

  double zoom = 1;
  MapPin? selected;

  final pins = <MapPin>[
    MapPin('Roller Coaster', 'Adventure Zone', 'North Loop', 25, const Offset(120, 210), const Color(0xFFE8504D), Icons.show_chart_rounded),
    MapPin('Drop Tower', 'Adventure Zone', 'Sky Drop Court', 18, const Offset(148, 450), const Color(0xFF8E63F7), Icons.vertical_align_bottom_rounded),
    MapPin('Ferris Wheel', 'Family Zone', 'Sunset Circle', 12, const Offset(520, 210), const Color(0xFFFFB443), Icons.circle_outlined),
    MapPin('Carousel', 'Kids Zone', 'Joy Square', 10, const Offset(350, 410), const Color(0xFFFF74A8), Icons.casino_outlined),
    MapPin('Bumper Cars', 'Kids Zone', 'Fun Garage', 15, const Offset(565, 535), const Color(0xFF4D8CFF), Icons.directions_car_filled_rounded),
    MapPin('Water Splash Ride', 'Water Zone', 'Aqua Bend', 8, const Offset(545, 360), const Color(0xFF16A6D9), Icons.water_drop_rounded),
    MapPin('Food Court', 'Food Court', 'Main Plaza', 0, const Offset(360, 820), const Color(0xFF65C8C0), Icons.fastfood_rounded),
    MapPin('Restrooms', 'Facility', 'Visitor block', 0, const Offset(610, 660), const Color(0xFF7D8B99), Icons.wc_rounded),
    MapPin('Ticket Counter', 'Entry Plaza', 'Bookings and support', 0, const Offset(285, 120), const Color(0xFF5C8DFF), Icons.confirmation_number_outlined),
    MapPin('First Aid', 'Facility', 'Medical support', 0, const Offset(618, 130), const Color(0xFF59A76E), Icons.medical_services_outlined),
    MapPin('Info Desk', 'Facility', 'Maps and guidance', 0, const Offset(95, 760), const Color(0xFFA078FF), Icons.info_outline_rounded),
    MapPin('Parking', 'Entry Plaza', 'Main parking area', 0, const Offset(110, 92), const Color(0xFF455A64), Icons.local_parking_rounded),
    MapPin('Entry Gate', 'Entry Plaza', 'Park entrance', 0, const Offset(128, 915), const Color(0xFF00A8A8), Icons.login_rounded),
    MapPin('Exit Gate', 'Entry Plaza', 'Park exit', 0, const Offset(610, 915), const Color(0xFFFF6B57), Icons.logout_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _mapAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _controller.addListener(() {
      final nextZoom = _controller.value.getMaxScaleOnAxis();
      if ((nextZoom - zoom).abs() > 0.05) {
        setState(() => zoom = nextZoom);
      }
    });
  }

  @override
  void dispose() {
    _mapAnimationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _resetView(Size viewport) {
    final scale = (viewport.width / 760).clamp(0.72, 1.05);
    final dx = (viewport.width - 760 * scale) / 2;
    final dy = 24.0;
    _controller.value = Matrix4.identity()
      ..translate(dx, dy)
      ..scale(scale);
  }

  void _zoomBy(double factor) {
    final current = _controller.value.getMaxScaleOnAxis();
    final target = (current * factor).clamp(0.7, 3.0);
    final ratio = target / current;
    _controller.value = _controller.value.scaled(ratio);
  }

  double _routeDistance(MapPin pin) {
    final dx = pin.position.dx - currentLocation.dx;
    final dy = pin.position.dy - currentLocation.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    return distance / 18;
  }

  int _routeMinutes(MapPin pin) {
    return (_routeDistance(pin) / 18 * 6).clamp(1, 25).round();
  }

  void _animateToPin(MapPin pin, Size viewport) {
    final currentMatrix = _controller.value;
    final targetScale = zoom < 1.25 ? 1.35 : zoom.clamp(1.25, 1.8);
    final dx = viewport.width / 2 - pin.position.dx * targetScale;
    final dy = viewport.height / 2 - pin.position.dy * targetScale;

    final targetMatrix = Matrix4.identity()
      ..translate(dx, dy)
      ..scale(targetScale);

    _mapAnimation = Matrix4Tween(begin: currentMatrix, end: targetMatrix).animate(
      CurvedAnimation(parent: _mapAnimationController, curve: Curves.easeInOutCubic),
    )
      ..addListener(() {
        _controller.value = _mapAnimation!.value;
      });

    _mapAnimationController
      ..reset()
      ..forward();
  }

  void _selectPin(MapPin pin, Size viewport) {
    setState(() => selected = pin);
    _animateToPin(pin, viewport);
    _showPlaceSheet(pin, viewport);
  }

  void _showPlaceSheet(MapPin pin, Size viewport) {
    final distance = _routeDistance(pin);
    final minutes = _routeMinutes(pin);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: const BoxDecoration(
            color: Color(0xFFF9FCFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 58,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: pin.color.withOpacity(0.14),
                      child: Icon(pin.icon, color: pin.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pin.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                          Text('${pin.zone} • ${pin.locationLabel}'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _sheetMetric('Route Distance', '${distance.toStringAsFixed(1)} m'),
                      ),
                      Expanded(
                        child: _sheetMetric('Walk Time', '$minutes min'),
                      ),
                      Expanded(
                        child: _sheetMetric('Wait Time', pin.waitMinutes == 0 ? 'Open' : '${pin.waitMinutes} min'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Navigate from your current location through the main walkway and turn into ${pin.zone}.',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _animateToPin(pin, viewport);
                        },
                        icon: const Icon(Icons.navigation_rounded),
                        label: const Text('Navigate'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                        label: const Text('Close'),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sheetMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailed = zoom > 1.2;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.search_rounded),
                    ),
                    Expanded(
                      child: Text(
                        selected == null ? 'Digital Park Map' : selected!.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(detailed ? 'Detail' : 'Overview'),
                    )
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.03),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final viewport = Size(constraints.maxWidth, constraints.maxHeight);
                    if (_controller.value == Matrix4.identity()) {
                      WidgetsBinding.instance.addPostFrameCallback((_) => _resetView(viewport));
                    }

                    return Stack(
                      children: [
                        Positioned.fill(
                          child: InteractiveViewer(
                            transformationController: _controller,
                            minScale: 0.7,
                            maxScale: 3.0,
                            constrained: false,
                            boundaryMargin: const EdgeInsets.all(120),
                            child: SizedBox(
                              width: 760,
                              height: 980,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: _MapPainter(
                                        currentLocation: currentLocation,
                                        selected: selected?.position,
                                      ),
                                    ),
                                  ),
                                  _zoneChip('Adventure Zone', 34, 28, const Color(0x30E8504D), const Color(0xFFE8504D)),
                                  _zoneChip('Family Zone', 500, 28, const Color(0x30FFB443), const Color(0xFFFFB443)),
                                  _zoneChip('Kids Zone', 290, 270, const Color(0x30FF74A8), const Color(0xFFFF74A8)),
                                  _zoneChip('Water Zone', 500, 250, const Color(0x3016A6D9), const Color(0xFF16A6D9)),
                                  _zoneChip('Food Court', 292, 780, const Color(0x3065C8C0), const Color(0xFF2E9F95)),
                                  _zoneChip('Entry Plaza', 70, 18, const Color(0x305C8DFF), const Color(0xFF5C8DFF)),
                                  ...pins.map((pin) => _buildPin(pin, detailed, viewport)),
                                  Positioned(
                                    left: currentLocation.dx - 16,
                                    top: currentLocation.dy - 16,
                                    child: _currentLocationMarker(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 16,
                          top: 14,
                          child: Column(
                            children: [
                              _fabControl(Icons.my_location_rounded, () {
                                setState(() {
                                  selected = MapPin(
                                    'Current Location',
                                    'Live Navigation',
                                    'Central Walkway',
                                    0,
                                    currentLocation,
                                    AppTheme.aqua,
                                    Icons.my_location_rounded,
                                  );
                                });
                              }),
                              const SizedBox(height: 10),
                              _fabControl(Icons.add_rounded, () => _zoomBy(1.18)),
                              const SizedBox(height: 10),
                              _fabControl(Icons.remove_rounded, () => _zoomBy(0.86)),
                              const SizedBox(height: 10),
                              _fabControl(Icons.center_focus_strong_rounded, () {
                                if (selected != null) {
                                  _animateToPin(selected!, viewport);
                                } else {
                                  _resetView(viewport);
                                }
                              }),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: selected == null
                                ? Container(
                                    key: const ValueKey('hint'),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.94),
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    child: const Text(
                                      'Pinch to zoom, drag to move, and tap any marker to open place details and navigation.',
                                    ),
                                  )
                                : Container(
                                    key: ValueKey(selected!.title),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.96),
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 18,
                                          offset: const Offset(0, 10),
                                        )
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: selected!.color.withOpacity(0.14),
                                          child: Icon(selected!.icon, color: selected!.color),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(selected!.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                                              const SizedBox(height: 4),
                                              Text('${_routeDistance(selected!).toStringAsFixed(1)} m • ${_routeMinutes(selected!)} min walk'),
                                            ],
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () => _showPlaceSheet(selected!, viewport),
                                          child: const Text('Navigate'),
                                        )
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _zoneChip(String label, double left, double top, Color bg, Color fg) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: fg.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: fg)),
      ),
    );
  }

  Widget _buildPin(MapPin pin, bool detailed, Size viewport) {
    return Positioned(
      left: pin.position.dx,
      top: pin.position.dy,
      child: GestureDetector(
        onTap: () => _selectPin(pin, viewport),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: pin.color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: pin.color.withOpacity(0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Icon(pin.icon, color: Colors.white, size: 18),
            ),
            if (detailed) ...[
              const SizedBox(height: 6),
              Container(
                constraints: const BoxConstraints(maxWidth: 120),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.94),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  pin.title,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]
          ],
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Widget _currentLocationMarker() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.aqua,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: AppTheme.aqua.withOpacity(0.28),
            blurRadius: 18,
            spreadRadius: 6,
          ),
        ],
      ),
    );
  }

  Widget _fabControl(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Icon(icon, color: AppTheme.navy),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  const _MapPainter({required this.currentLocation, this.selected});

  final Offset currentLocation;
  final Offset? selected;

  @override
  void paint(Canvas canvas, Size size) {
    final green = Paint()..color = const Color(0xFFDFF3E7);
    final family = Paint()..color = const Color(0xFFFFF3DB);
    final kids = Paint()..color = const Color(0xFFFCE2EE);
    final blue = Paint()..color = const Color(0xFFD8F0FF);
    final road = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 28
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final roadOutline = Paint()
      ..color = const Color(0x22000000)
      ..strokeWidth = 34
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFFF3F6F7));
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(26, 88, 220, 440), const Radius.circular(38)), green);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(430, 88, 260, 200), const Radius.circular(38)), family);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(260, 300, 250, 310), const Radius.circular(38)), kids);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(500, 250, 190, 230), const Radius.circular(38)), blue);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(250, 770, 280, 120), const Radius.circular(28)), green);

    final mainRoad = Path()
      ..moveTo(120, 120)
      ..quadraticBezierTo(290, 180, 470, 180)
      ..quadraticBezierTo(610, 180, 640, 320)
      ..quadraticBezierTo(650, 500, 535, 620)
      ..quadraticBezierTo(430, 735, 330, 880);
    canvas.drawPath(mainRoad, roadOutline);
    canvas.drawPath(mainRoad, road);

    canvas.drawLine(const Offset(330, 180), const Offset(330, 365), roadOutline);
    canvas.drawLine(const Offset(330, 180), const Offset(330, 365), road);
    canvas.drawLine(const Offset(170, 475), const Offset(330, 475), roadOutline);
    canvas.drawLine(const Offset(170, 475), const Offset(330, 475), road);
    canvas.drawLine(const Offset(530, 585), const Offset(610, 585), roadOutline);
    canvas.drawLine(const Offset(530, 585), const Offset(610, 585), road);

    if (selected != null) {
      final routePaint = Paint()
        ..color = AppTheme.coral
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final path = Path()
        ..moveTo(currentLocation.dx, currentLocation.dy)
        ..lineTo(currentLocation.dx, 610)
        ..lineTo(330, 610)
        ..lineTo(330, selected!.dy)
        ..lineTo(selected!.dx, selected!.dy);
      canvas.drawPath(path, routePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) => oldDelegate.selected != selected;
}

class MapPin {
  MapPin(this.title, this.zone, this.locationLabel, this.waitMinutes, this.position, this.color, this.icon);

  final String title;
  final String zone;
  final String locationLabel;
  final int waitMinutes;
  final Offset position;
  final Color color;
  final IconData icon;

  String get subtitle => waitMinutes == 0 ? '$zone • $locationLabel' : '$zone • $waitMinutes min wait';
}
