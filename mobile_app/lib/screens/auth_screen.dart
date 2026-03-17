import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../services/auth_service.dart';
import '../widgets/glass_panel.dart';
import '../widgets/gradient_background.dart';
import 'home_shell.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool isLogin = true;
  bool loading = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController(text: 'rahul@gmail.com');
  final phoneController = TextEditingController();
  final ageController = TextEditingController();
  final passwordController = TextEditingController(text: 'visitor123');

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => loading = true);

    try {
      final session = isLogin
          ? await _authService.login(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
            )
          : await _authService.register(
              name: nameController.text.trim(),
              email: emailController.text.trim(),
              phone: phoneController.text.trim(),
              age: int.parse(ageController.text.trim()),
              password: passwordController.text.trim(),
            );

      if (!mounted) {
        return;
      }

      Navigator.pushReplacementNamed(
        context,
        HomeShell.routeName,
        arguments: session.role,
      );
    } on FormatException {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid age before registering.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      final message = error.toString();
      final readableMessage = message.contains('TimeoutException')
          ? 'The server took too long to respond. If you are using the free hosted backend, please wait a few seconds and try again.'
          : message.replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            readableMessage,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: SingleChildScrollView(
                child: GlassPanel(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLogin ? 'Welcome back to the park' : 'Create your visitor profile',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 24),
                        if (!isLogin) ...[
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(labelText: 'Name'),
                            validator: (value) => value == null || value.isEmpty ? 'Enter your name' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: phoneController,
                            decoration: const InputDecoration(labelText: 'Phone'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: ageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Age'),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter your age';
                              }
                              final parsed = int.tryParse(value.trim());
                              if (parsed == null || parsed <= 0) {
                                return 'Enter a valid age';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (value) => value == null || value.isEmpty ? 'Enter your email' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'Password'),
                          validator: (value) => value == null || value.length < 6 ? 'Minimum 6 characters' : null,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: loading ? null : _submit,
                            child: Text(loading ? 'Please wait...' : (isLogin ? 'Login' : 'Register')),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => isLogin = !isLogin),
                          child: Text(isLogin ? 'Create a visitor account' : 'Already have an account? Login'),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.08),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
