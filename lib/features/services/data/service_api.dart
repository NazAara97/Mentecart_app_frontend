import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mentecart_app/features/services/models/service_model.dart';

class ServiceApi {
  static const String baseUrl = "http://192.168.1.101:3000"; 
 

  Future<List<Service>> fetchServices() async {
    final url = Uri.parse("$baseUrl/services/");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => Service.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load services");
    }
  }



  Future<Service> fetchServiceById(String id) async {
  final url = Uri.parse("$baseUrl/services/$id");

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return Service.fromJson(data);
  } else {
    throw Exception("Failed to load service");
  }
}
}