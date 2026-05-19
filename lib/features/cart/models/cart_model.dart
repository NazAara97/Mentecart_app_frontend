import 'package:mentecart_app/features/services/models/service_model.dart';

class CartItem {
  final String id;
  final Service service;
  final int quantity;

  CartItem({
    required this.id,
    required this.service,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['_id'],
      service: Service.fromJson(json['serviceId']),
      quantity: json['quantity'] ?? 1,
    );
  }

  String? get createdAt => null;
}

class Cart {
  final List<CartItem> items;

  Cart({required this.items});

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      items: (json['items'] as List)
          .map((e) => CartItem.fromJson(e))
          .toList(),
    );
  }
}
