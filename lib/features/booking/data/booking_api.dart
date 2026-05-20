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
  List items
) async {
  final headers = await getAuthHeaders();

  final body = {
    "appointmentDate": appointmentDate.toIso8601String(),
    "items": items.map((e) => {
      "serviceId": e.service.id ?? e.service["_id"], // ✅ FIXED
      "quantity": e.quantity,
      "price": e.service.price,
        // ✅ REQUIRED (THIS FIXES YOUR ISSUE)
      "date": e.date,
      "time": e.time,
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
// 💳 PAY WITH CARD
Future<Map<String, dynamic>> payWithCard({
  required String bookingId,
  required String cardHolderName,
  required String cardNumber,
  required String expiryMonth,
  required String expiryYear,
}) async {
  final headers = await getAuthHeaders();

  final body = {
    "transactionId": DateTime.now().millisecondsSinceEpoch.toString(),
    "cardHolderName": cardHolderName,
    "cardNumber": cardNumber,
    "expiryMonth": expiryMonth,
    "expiryYear": expiryYear,
  };

  final res = await http.post(
    Uri.parse("$baseUrl/bookings/$bookingId/pay-card"),
    headers: headers,
    body: jsonEncode(body),
  );

  print("CARD PAYMENT STATUS: ${res.statusCode}");
  print("CARD PAYMENT BODY: ${res.body}");

  if (res.statusCode != 200) {
    throw Exception("Card payment failed: ${res.body}");
  }

  return jsonDecode(res.body);
}


// 💵 PAY WITH CASH
Future<Map<String, dynamic>> payWithCash(String bookingId) async {
  final headers = await getAuthHeaders();

  final res = await http.post(
    Uri.parse("$baseUrl/bookings/$bookingId/pay-cash"),
    headers: headers,
  );

  print("CASH PAYMENT STATUS: ${res.statusCode}");
  print("CASH PAYMENT BODY: ${res.body}");

  if (res.statusCode != 200) {
    throw Exception("Cash payment failed: ${res.body}");
  }

  return jsonDecode(res.body);
}
  
}