class BookingItem {
  final String serviceId;
  final int quantity;
  final double price;

  BookingItem({
    required this.serviceId,
    required this.quantity,
    required this.price,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    return BookingItem(
      serviceId: json['serviceId'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "serviceId": serviceId,
      "quantity": quantity,
      "price": price,
    };
  }
}

class Booking {
  final String id;
  final List<BookingItem> items;
  final DateTime appointmentDate;
  final double totalAmount;
  final String status;

  Booking({
    required this.id,
    required this.items,
    required this.appointmentDate,
    required this.totalAmount,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'],
      items: (json['items'] as List)
          .map((e) => BookingItem.fromJson(e))
          .toList(),
      appointmentDate: DateTime.parse(json['appointmentDate']),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'],
    );
  }
}