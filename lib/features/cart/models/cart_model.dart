import 'package:mentecart_app/features/services/models/service_model.dart';

class CartItem {
  final String id;
  final Service service;
  final int quantity;
  final String date;
  final String time;

  CartItem({
    required this.id,
    required this.service,
    required this.quantity,
    required this.date,
    required this.time,
  });
factory CartItem.fromJson(Map<String, dynamic> json) {
  return CartItem(
    id: json['_id'] ?? "",

    quantity: json['quantity'] ?? 1,

    date: json['date'],
    time: json['time'],

    /// 🔥 FIX HERE
    service: json['service'] != null
        ? Service.fromJson(json['service'])
        : Service.empty(), // 
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
