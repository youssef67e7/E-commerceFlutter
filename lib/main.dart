// ignore_for_file: unused_import

import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:ecommerce_app/providers/auth_provider.dart';
import 'package:ecommerce_app/providers/products_provider.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/providers/orders_provider.dart';
import 'package:ecommerce_app/providers/favorites_provider.dart';
import 'package:ecommerce_app/providers/theme_provider.dart';
import 'package:ecommerce_app/screens/main_screen.dart';
import 'package:ecommerce_app/screens/product_detail_screen.dart';
import 'package:ecommerce_app/screens/register_screen.dart';
import 'package:ecommerce_app/screens/test_messaging_screen.dart';
import 'package:ecommerce_app/screens/firebase_test_screen.dart';
import 'package:ecommerce_app/services/notification_service.dart';
import 'package:ecommerce_app/services/storage_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

// Import Firebase core
import 'package:firebase_core/firebase_core.dart';

// Import Firebase options
import 'package:ecommerce_app/firebase_options.dart';

// Declare notification service as a global variable
final notificationService = NotificationService();

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase only on supported platforms
    bool shouldInitializeFirebase = true;

    // Skip Firebase initialization on Windows for now due to potential issues
    if (defaultTargetPlatform == TargetPlatform.windows && !kIsWeb) {
      shouldInitializeFirebase = false;
    }

    if (shouldInitializeFirebase) {
      try {
        // Initialize Firebase for web and mobile platforms
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );

        // Initialize Firebase Messaging
        final fcm = FirebaseMessaging.instance;
        await fcm.requestPermission();
        final token = await fcm.getToken();

        // Set up background message handler
        FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler,
        );
      } catch (firebaseError) {
        // Continue app startup even if Firebase fails - demo mode will be used
      }
    }

    // Initialize local storage
    await StorageService.init();

    // Initialize notification service
    await notificationService.initialize();
  } catch (e) {
    // Continue app startup even if some services fail
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => ProductsProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => OrdersProvider()),
        ChangeNotifierProvider(create: (context) => FavoritesProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Luxury',
          theme: ThemeProvider.lightTheme,
          darkTheme: ThemeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const MainScreen(),
          debugShowCheckedModeBanner: false,
          routes: {
            '/product-detail': (context) => const ProductDetailScreen(),
            '/register': (context) => const RegisterScreen(),
            '/test-messaging': (context) => const TestMessagingScreen(),
            '/firebase-test': (context) => const FirebaseTestScreen(),
          },
          // Add error handler for the entire app
          builder: (context, widget) {
            ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
              return const Scaffold(
                body: Center(
                  child: Text(
                    'Something went wrong. Please restart the app.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              );
            };
            return widget!;
          },
        );
      },
    );
  }
}
