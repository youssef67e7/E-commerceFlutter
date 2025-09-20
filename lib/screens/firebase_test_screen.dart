import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecommerce_app/providers/auth_provider.dart' as app_auth;
import 'package:provider/provider.dart';

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _status = 'Not tested yet';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _testAuth() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing authentication...';
    });

    try {
      final authProvider = Provider.of<app_auth.AuthProvider>(
        context,
        listen: false,
      );

      // Test if Firebase is properly configured
      final auth = FirebaseAuth.instance;
      final isConfigured = auth.app != null;

      setState(() {
        _status =
            isConfigured
                ? '✅ Firebase is properly configured!'
                : '❌ Firebase configuration issue';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Configuration Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Firebase Configuration Test',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'This screen tests if your Firebase configuration is working properly.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _status,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Configuration Values:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Project ID: youssef-5228c'),
            const Text('Project Number: 293546416514'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _testAuth,
              child:
                  _isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      )
                      : const Text('Test Firebase Configuration'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Next Steps:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '1. Get your Google Sign-In Web Client ID from Firebase Console',
            ),
            const Text('2. Update it in lib/providers/auth_provider.dart'),
            const Text(
              '3. Enable Email/Password and Google authentication in Firebase Console',
            ),
          ],
        ),
      ),
    );
  }
}
