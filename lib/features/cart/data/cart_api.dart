import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mentecart_app/features/cart/models/cart_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartApi {
  static const String baseUrl = "http://192.168.1.101:3000";

  /// ✅ GET TOKEN
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    print("FETCHED TOKEN: $token"); // debug

    return token;
  }

  /// ✅ COMMON HEADERS WITH TOKEN
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

  
   
   /// ✅ GET CART
  Future<Cart> fetchCart() async {
    final url = Uri.parse("$baseUrl/cart/");
    final headers = await getAuthHeaders();

    final response = await http.get(url, headers: headers);

    print("GET CART STATUS: ${response.statusCode}");
    print("GET CART BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Cart.fromJson(data);
    } else {
      throw Exception("Failed to load cart");
    }
  }

  /// ✅ ADD TO CART WITH DATE & TIME
  Future<void> addToCart(
  String serviceId,
  DateTime date,
  TimeOfDay time,
) async {
  final url = Uri.parse("$baseUrl/cart/items");
  final headers = await getAuthHeaders();

  final formattedDate =
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  final formattedTime =
      "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

  final body = jsonEncode({
    "serviceId": serviceId,
    "date": formattedDate,
    "time": formattedTime,
    "quantity": 1,
  });

  print("REQUEST BODY: $body"); // 👈 DEBUG (VERY IMPORTANT)

  final response = await http.post(
    url,
    headers: headers,
    body: body,
  );

  print("STATUS: ${response.statusCode}");
  print("BODY: ${response.body}");

  if (response.statusCode != 200) {
    throw Exception(response.body);
  }
}

   // ✅ UPDATE ITEM
  Future<void> updateCartItem(String itemId, int quantity) async {
    final url = Uri.parse("$baseUrl/cart/items/$itemId");
    final headers = await getAuthHeaders();

    final response = await http.patch(
      url,
      headers: headers,
      body: jsonEncode({
        "quantity": quantity,
       
      }),
    );

    print("UPDATE STATUS: ${response.statusCode}");
    print("UPDATE BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to update item");
    }
  }
  // ✅ DELETE ITEM
  Future<void> removeItem(String itemId) async {
    final url = Uri.parse("$baseUrl/cart/items/$itemId");
    final headers = await getAuthHeaders();

    final response = await http.delete(url, headers: headers);

    print("DELETE STATUS: ${response.statusCode}");
    print("DELETE BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }

  Future<void> clearCart() async {
  final url = Uri.parse("$baseUrl/cart/clear");
  final headers = await getAuthHeaders();

  final response = await http.delete(url, headers: headers);

  print("CLEAR CART STATUS: ${response.statusCode}");
  print("CLEAR CART BODY: ${response.body}");

  if (response.statusCode != 200) {
    throw Exception("Failed to clear cart");
  }
}

 


}