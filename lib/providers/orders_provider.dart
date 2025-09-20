import 'package:flutter/material.dart';
import 'package:ecommerce_app/models/order.dart';
import 'package:ecommerce_app/models/cart_item.dart';
import 'package:ecommerce_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrdersProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<AppOrder> _orders = [];

  List<AppOrder> get orders => [..._orders];

  OrdersProvider() {
    _loadOrders();
  }

  // Load orders from Firestore
  void _loadOrders() {
    if (_auth.currentUser != null) {
      _firestoreService.getOrders(_auth.currentUser!.uid).listen((orders) {
        _orders = orders;
        notifyListeners();
      });
    }
  }

  // Add order and save to Firestore
  Future<void> addOrder(List<CartItem> cartItems, double total) async {
    if (_auth.currentUser == null) {
      throw Exception('User not authenticated');
    }

    final order = AppOrder(
      id: DateTime.now().toString(),
      products: cartItems,
      orderDate: DateTime.now(),
      totalAmount: total,
      status: 'Pending',
    );

    // Save to Firestore
    await _firestoreService.saveOrder(_auth.currentUser!.uid, order);

    // Add to local list
    _orders.insert(0, order);
    notifyListeners();
  }
}
