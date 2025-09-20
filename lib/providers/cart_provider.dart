import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce_app/models/cart_item.dart';
import 'package:ecommerce_app/models/product.dart';
import 'dart:convert';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  static const String _cartKey = 'cart_items';

  List<CartItem> get items => [..._items];
  int get itemCount => _items.length;
  double get totalAmount {
    double total = 0.0;
    for (var item in _items) {
      total += item.totalPrice;
    }
    return total;
  }

  CartProvider() {
    _loadCartFromPreferences();
  }

  // Load cart from SharedPreferences
  Future<void> _loadCartFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString(_cartKey);

      if (cartData != null) {
        final List<dynamic> decodedData = json.decode(cartData);
        _items.clear();
        _items.addAll(
          decodedData.map((itemData) {
            final productData = itemData['product'];
            final product = Product(
              id: productData['id'],
              title: productData['title'],
              description: productData['description'],
              price: productData['price'].toDouble(),
              imageUrl: productData['imageUrl'],
              category: productData['category'],
              rating: productData['rating'].toDouble(),
              reviewCount: productData['reviewCount'],
            );

            return CartItem(
              id: itemData['id'],
              product: product,
              quantity: itemData['quantity'],
            );
          }).toList(),
        );
        notifyListeners();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // Save cart to SharedPreferences
  Future<void> _saveCartToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData =
          _items.map((item) {
            return {
              'id': item.id,
              'product': {
                'id': item.product.id,
                'title': item.product.title,
                'description': item.product.description,
                'price': item.product.price,
                'imageUrl': item.product.imageUrl,
                'category': item.product.category,
                'rating': item.product.rating,
                'reviewCount': item.product.reviewCount,
              },
              'quantity': item.quantity,
            };
          }).toList();

      final String encodedData = json.encode(cartData);
      await prefs.setString(_cartKey, encodedData);
    } catch (e) {
      // Handle error silently
    }
  }

  void addItem(Product product) {
    // Check if the item is already in the cart
    final existingItemIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingItemIndex >= 0) {
      // If item exists, increase quantity
      _items[existingItemIndex].quantity++;
    } else {
      // If item doesn't exist, add new item
      _items.add(
        CartItem(id: DateTime.now().toString(), product: product, quantity: 1),
      );
    }
    notifyListeners();
    _saveCartToPreferences();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
    _saveCartToPreferences();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
    _saveCartToPreferences();
  }

  void updateQuantity(String cartItemId, int quantity) {
    if (quantity <= 0) {
      removeItem(cartItemId);
      return;
    }

    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      _items[index].quantity = quantity;
      notifyListeners();
      _saveCartToPreferences();
    }
  }
}
