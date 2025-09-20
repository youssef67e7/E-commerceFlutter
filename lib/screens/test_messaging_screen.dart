import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ecommerce_app/services/notification_service.dart';

class TestMessagingScreen extends StatefulWidget {
  const TestMessagingScreen({super.key});

  @override
  State<TestMessagingScreen> createState() => _TestMessagingScreenState();
}

class _TestMessagingScreenState extends State<TestMessagingScreen> {
  String _token = 'Not retrieved yet';
  String _message = 'No messages received';

  @override
  void initState() {
    super.initState();
    _initializeMessaging();
  }

  Future<void> _initializeMessaging() async {
    try {
      // Get FCM token
      final fcmToken = await FirebaseMessaging.instance.getToken();
      setState(() {
        _token = fcmToken ?? 'Failed to get token';
      });

      // Listen for messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        setState(() {
          _message = 'Received message: ${message.notification?.title}';
        });
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        setState(() {
          _message = 'Message opened: ${message.notification?.title}';
        });
      });
    } catch (e) {
      setState(() {
        _token = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Messaging Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FCM Token:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _token,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Messages:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_message),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeMessaging,
              child: const Text('Refresh Token'),
            ),
          ],
        ),
      ),
    );
  }
}
