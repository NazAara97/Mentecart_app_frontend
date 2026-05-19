import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mentecart_app/core/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingApi {
  static const String baseUrl = "http://192.168.1.101:3000";

  BookingApi(ApiService apiService);

  /// ✅ GET TOKEN
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    print("FETCHED TOKEN: $token");
    return token;
  }

  /// ✅ HEADERS
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();

    if (token == null) {
      throw Exception("User not logged in");
    }

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // 🧾 CHECKOUT
  Future<Map<String, dynamic>> checkout(
  DateTime appointmentDate,
  List items,
) async {
  final headers = await getAuthHeaders();

  final body = {
    "appointmentDate": appointmentDate.toIso8601String(),
    "items": items.map((e) => {
      "serviceId": e.service.id ?? e.service["_id"], // ✅ FIXED
      "quantity": e.quantity,
      "price": e.service.price,
    }).toList(),
  };

  print("SENDING BODY: ${jsonEncode(body)}");
  print("HEADERS: $headers");

  final res = await http.post(
    Uri.parse("$baseUrl/bookings/checkout"),
    headers: headers, // ✅ FIXED
    body: jsonEncode(body),
  );

  print("CHECKOUT STATUS: ${res.statusCode}");
  print("CHECKOUT BODY: ${res.body}");

  if (res.statusCode != 201) {
    throw Exception("Checkout failed: ${res.body}");
  }

  return jsonDecode(res.body);
}
  // 📄 GET BOOKINGS
  Future<List<dynamic>> getBookings() async {
    final headers = await getAuthHeaders();

    final res = await http.get(
      Uri.parse("$baseUrl/bookings/"),
      headers: headers,
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to fetch bookings");
    }

    return jsonDecode(res.body);
  }

  // 🔍 SINGLE BOOKING
  Future<Map<String, dynamic>> getBookingById(String id, Map map) async {
  final headers = await getAuthHeaders();

  final res = await http.get(
    Uri.parse("$baseUrl/bookings/$id"),
    headers: headers,
  );

  print("GET BOOKING STATUS: ${res.statusCode}");
  print("GET BOOKING BODY: ${res.body}");

  if (res.statusCode < 200 || res.statusCode >= 300) {
    throw Exception("Failed to fetch booking: ${res.body}");
  }

  return jsonDecode(res.body);
}

  // ❌ CANCEL
  Future<void> cancelBooking(String id) async {
  final headers = await getAuthHeaders();

  final res = await http.post(
    Uri.parse("$baseUrl/bookings/$id/cancel"),
    headers: headers,
  );

  print("CANCEL STATUS: ${res.statusCode}");
  print("CANCEL BODY: ${res.body}");

  if (res.statusCode != 200) {
    throw Exception("Cancel failed");
  }
}

  // 💳 PAYMENT
  Future<Map<String, dynamic>> payment(
  String bookingId,
  String method,
  String transactionId, {
  String? cardHolderName,
  String? cardNumber,
  String? expiryMonth,
  String? expiryYear,
}) async {
  final headers = await getAuthHeaders();

  final res = await http.post(
    Uri.parse("$baseUrl/bookings/$bookingId/payment"),
    headers: headers,
    body: jsonEncode({
      "method": method,
      "transactionId": transactionId,

      // 💳 send card data
      "cardHolderName": cardHolderName,
      "cardNumber": cardNumber,
      "expiryMonth": expiryMonth,
      "expiryYear": expiryYear,
    }),
  );

  print("PAYMENT STATUS: ${res.statusCode}");
  print("PAYMENT BODY: ${res.body}");

  if (res.statusCode != 200) {
    throw Exception("Payment failed");
  }

  return jsonDecode(res.body);
}
}