import 'package:ecommerce_app/models/cart_item.dart';

class AppOrder {
  final String id;
  final List<CartItem> products;
  final DateTime orderDate;
  final double totalAmount;
  final String status;

  AppOrder({
    required this.id,
    required this.products,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
  });
}
