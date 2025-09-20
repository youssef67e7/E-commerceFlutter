import 'package:flutter/material.dart';
import 'package:ecommerce_app/models/product.dart';
import 'package:ecommerce_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Product> _favorites = [];

  List<Product> get favorites => [..._favorites];
  int get favoritesCount => _favorites.length;

  FavoritesProvider() {
    _loadFavorites();
  }

  // Load favorites from Firestore
  void _loadFavorites() {
    if (_auth.currentUser != null) {
      _firestoreService.getFavorites(_auth.currentUser!.uid).listen((favorites) {
        _favorites = favorites;
        notifyListeners();
      });
    }
  }

  // Add product to favorites
  Future<void> addFavorite(Product product) async {
    if (_auth.currentUser == null) {
      throw Exception('User not authenticated');
    }

    await _firestoreService.saveFavorite(_auth.currentUser!.uid, product);
    _favorites.add(product);
    notifyListeners();
  }

  // Remove product from favorites
  Future<void> removeFavorite(String productId) async {
    if (_auth.currentUser == null) {
      throw Exception('User not authenticated');
    }

    await _firestoreService.removeFavorite(_auth.currentUser!.uid, productId);
    _favorites.removeWhere((product) => product.id == productId);
    notifyListeners();
  }

  // Check if product is favorite
  bool isFavorite(String productId) {
    return _favorites.any((product) => product.id == productId);
  }
}