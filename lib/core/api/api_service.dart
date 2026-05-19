import 'package:dio/dio.dart';

class ApiService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://192.168.1.101:3000", 
      headers: {
        "Content-Type": "application/json",
      },
    ),
  );

  
  // SIGNUP
  Future<Response> signup(String email, String password) async {
    return await dio.post(
      "/auth/signup",
      data: {
        "email": email,
        "password": password,
      },
    );
  }

  // LOGIN (we will add backend later)
  Future<Response> login(String email, String password) async {
    return await dio.post(
      "/auth/login",
      data: {
        "email": email,
        "password": password,
      },
    );
  }
}