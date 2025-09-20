import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecommerce_app/models/product.dart';
import 'package:ecommerce_app/models/order.dart';
import 'package:ecommerce_app/models/cart_item.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save product to favorites
  Future<void> saveFavorite(String userId, Product product) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(product.id)
        .set({
          'id': product.id,
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'category': product.category,
          'rating': product.rating,
          'reviewCount': product.reviewCount,
          'savedAt': FieldValue.serverTimestamp(),
        });
  }

  // Remove product from favorites
  Future<void> removeFavorite(String userId, String productId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(productId)
        .delete();
  }

  // Get user favorites
  Stream<List<Product>> getFavorites(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Product(
              id: data['id'],
              title: data['title'],
              description: data['description'],
              price: data['price'].toDouble(),
              imageUrl: data['imageUrl'],
              category: data['category'],
              rating: data['rating'].toDouble(),
              reviewCount: data['reviewCount'],
            );
          }).toList();
        });
  }

  // Save order
  Future<void> saveOrder(String userId, AppOrder order) async {
    await _firestore.collection('users').doc(userId).collection('orders').add({
      'orderId': order.id,
      'products':
          order.products.map((item) {
            return {
              'id': item.id,
              'productId': item.product.id,
              'productTitle': item.product.title,
              'productPrice': item.product.price,
              'quantity': item.quantity,
              'totalPrice': item.totalPrice,
            };
          }).toList(),
      'orderDate': order.orderDate,
      'totalAmount': order.totalAmount,
      'status': order.status,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get user orders
  Stream<List<AppOrder>> getOrders(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            final products =
                (data['products'] as List).map((item) {
                  return CartItem(
                    id: item['id'],
                    product: Product(
                      id: item['productId'],
                      title: item['productTitle'],
                      description: '',
                      price: item['productPrice'].toDouble(),
                      imageUrl: '',
                      category: '',
                      rating: 0.0,
                      reviewCount: 0,
                    ),
                    quantity: item['quantity'],
                  );
                }).toList();

            return AppOrder(
              id: data['orderId'],
              products: products,
              orderDate: (data['orderDate'] as Timestamp).toDate(),
              totalAmount: data['totalAmount'].toDouble(),
              status: data['status'],
            );
          }).toList();
        });
  }

  // Save user profile
  Future<void> saveUserProfile(
    String userId,
    Map<String, dynamic> profileData,
  ) async {
    await _firestore.collection('users').doc(userId).update({
      'profile': profileData,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data()?['profile'];
  }

  // Create user data in Firestore
  Future<void> createUserData(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'isActive': true,
    });
  }

  // Update user data in Firestore
  Future<void> updateUserData(User user) async {
    await _firestore.collection('users').doc(user.uid).update({
      'lastLogin': FieldValue.serverTimestamp(),
      'displayName': user.displayName,
      'photoURL': user.photoURL,
    });
  }

  // Delete user data from Firestore
  Future<void> deleteUserData(String userId) async {
    final batch = _firestore.batch();

    // Delete user document
    batch.delete(_firestore.collection('users').doc(userId));

    // Delete user's favorites
    final favoritesQuery =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .get();

    for (final doc in favoritesQuery.docs) {
      batch.delete(doc.reference);
    }

    // Delete user's orders
    final ordersQuery =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('orders')
            .get();

    for (final doc in ordersQuery.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
