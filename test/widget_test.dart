// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/main.dart';
import 'package:ecommerce_app/providers/products_provider.dart';

void main() {
  testWidgets('App loads and displays main screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ProductsProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the app title is displayed
    expect(find.text('Luxury'), findsWidgets);

    // Verify that category section is present
    expect(find.text('Shop by Category'), findsWidgets);
  });
}