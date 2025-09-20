import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Track if the service has been initialized
  bool _isInitialized = false;

  // Track active listeners to prevent duplicates
  StreamSubscription? _productsListener;
  StreamSubscription? _ordersListener;

  Future<void> initialize() async {
    // Prevent multiple initializations
    if (_isInitialized) {
      return;
    }

    try {
      // Initialize Firebase Messaging
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Get the FCM token
      final fcmToken = await _firebaseMessaging.getToken();

      // Configure local notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await _notificationsPlugin.initialize(initializationSettings);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          showNotification(
            DateTime.now().millisecondsSinceEpoch ~/ 1000,
            message.notification!.title ?? 'New Notification',
            message.notification!.body ?? 'You have a new notification',
          );
        }
      });

      // Handle message opening
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
    } catch (e) {
      // Ignore initialization errors on web platform
    }

    _isInitialized = true;
  }

  // Background message handler
  Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    // Handle background message here
  }

  Future<void> showNotification(int id, String title, String body) async {
    // Ensure service is initialized before showing notifications
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
            'ecommerce_channel',
            'E-Commerce Notifications',
            channelDescription: 'Notifications for new products and orders',
            importance: Importance.max,
            priority: Priority.high,
          );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
      );

      await _notificationsPlugin.show(id, title, body, notificationDetails);
    } catch (e) {
      // Ignore notification errors on web platform
    }
  }

  // Set up listeners for new product offers
  void listenForNewProducts() {
    // Cancel existing listener if any
    _productsListener?.cancel();

    // Listen for new products in Firestore
    _productsListener = _firestore
        .collection('new_products')
        .orderBy('created_at', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final product = snapshot.docs.first.data();
            showNotification(
              DateTime.now().millisecondsSinceEpoch ~/ 1000,
              'New Product Alert!',
              'Check out our new product: ${product['name']}',
            );
          }
        });
  }

  // Set up listeners for order status updates
  void listenForOrderUpdates() {
    // Cancel existing listener if any
    _ordersListener?.cancel();

    // Only listen if user is authenticated
    if (_auth.currentUser != null) {
      _ordersListener = _firestore
          .collection('orders')
          .where('user_id', isEqualTo: _auth.currentUser!.uid)
          .snapshots()
          .listen((snapshot) {
            for (var change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.added) {
                final order = change.doc.data() as Map<String, dynamic>;
                showNotification(
                  DateTime.now().millisecondsSinceEpoch ~/ 1000,
                  'Order Update',
                  'Your order #${order['order_number']} has been confirmed!',
                );
              }
            }
          });
    }
  }

  // Cleanup method to cancel listeners
  void dispose() {
    _productsListener?.cancel();
    _ordersListener?.cancel();
    _isInitialized = false;
  }
}
