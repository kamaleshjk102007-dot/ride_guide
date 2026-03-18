import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/user_session.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/gradient_background.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  final SessionService _sessionService = SessionService();
  String fullName = 'Rahul Kumar';
  String email = 'rahul@gmail.com';
  String phone = '+91 9876543210';
  String visitorId = 'VST----';
  String accountStatus = 'Active';
  int? age;
  File? profileImage;
  UserSession? _currentSession;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final session = await _sessionService.loadSession();
    if (!mounted || session == null) {
      return;
    }

    final savedImagePath = session.profileImagePath;
    final savedImage = savedImagePath != null && savedImagePath.isNotEmpty ? File(savedImagePath) : null;

    setState(() {
      _currentSession = session;
      fullName = session.name.isEmpty ? fullName : session.name;
      email = session.email.isEmpty ? email : session.email;
      phone = (session.phone == null || session.phone!.isEmpty) ? phone : session.phone!;
      age = session.age;
      visitorId = session.visitorId.isEmpty ? visitorId : session.visitorId;
      accountStatus = (session.status == null || session.status!.isEmpty) ? accountStatus : session.status!;
      if (savedImage != null && savedImage.existsSync()) {
        profileImage = savedImage;
      }
    });
  }

  Future<void> _persistProfile() async {
    final session = _currentSession;
    if (session == null) {
      return;
    }

    await _sessionService.saveSession(
      UserSession(
        token: session.token,
        role: session.role,
        userId: session.userId,
        visitorId: session.visitorId,
        name: fullName,
        email: email,
        phone: phone,
        age: age,
        status: session.status,
        profileImagePath: profileImage?.path,
      ),
    );
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: fullName);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF9FCFF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
                    Text(
                      'Edit profile',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You can update your profile picture and full name.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Profile Picture',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppTheme.coral.withOpacity(0.35),
                            width: 2,
                          ),
                        ),
                        child: _profileAvatar(radius: 34),
                      ),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await _picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          final imageFile = File(picked.path);
                          setState(() {
                            profileImage = imageFile;
                          });
                          await _persistProfile();
                          if (!mounted) {
                            return;
                          }
                        }
                      },
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Choose from gallery'),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            fullName = nameController.text.trim().isEmpty ? fullName : nameController.text.trim();
                          });
                          await _persistProfile();
                          if (!mounted) {
                            return;
                          }
                          Navigator.pop(context);
                        },
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
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
      appBar: AppBar(title: const Text('Profile')),
      body: GradientBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GlassPanel(
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _profileAvatar(radius: 54),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: InkWell(
                          onTap: _editProfile,
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: AppTheme.coral,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    fullName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Visitor Profile',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.05),
            const SizedBox(height: 18),
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),
                  _infoTile(Icons.badge_outlined, 'Full Name', fullName),
                  _infoTile(Icons.email_outlined, 'Email Address', email),
                  _infoTile(Icons.phone_outlined, 'Phone Number', phone),
                  _infoTile(Icons.cake_outlined, 'Age', age?.toString() ?? 'Not available'),
                  _infoTile(Icons.confirmation_number_outlined, 'Visitor ID', visitorId),
                  _infoTile(Icons.verified_user_outlined, 'Status', accountStatus),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Action',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFEAFBFF),
                      child: Icon(Icons.settings_outlined, color: AppTheme.aqua),
                    ),
                    title: const Text('Profile settings'),
                    subtitle: const Text('Change your profile photo and full name'),
                    onTap: _editProfile,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B57),
                      ),
                      onPressed: () async {
                        await _sessionService.clearSession();
                        if (!mounted) {
                          return;
                        }
                        Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
                      },
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Logout'),
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

  Widget _profileAvatar({double radius = 54}) {
    if (profileImage != null) {
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: FileImage(profileImage!),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 18,
              offset: const Offset(0, 10),
            )
          ],
        ),
        );
    }

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFF1EE),
        boxShadow: [
          BoxShadow(
            color: AppTheme.coral.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Icon(Icons.person_rounded, color: AppTheme.coral, size: radius),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFFFF3EF),
            child: Icon(icon, color: AppTheme.coral),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
