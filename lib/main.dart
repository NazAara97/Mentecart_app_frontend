import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mentecart_app/features/booking/bloc/book_bloc.dart';
import 'package:mentecart_app/features/booking/data/booking_api.dart';
import 'package:mentecart_app/features/cart/bloc/cart_bloc.dart';
import 'package:mentecart_app/features/cart/data/cart_api.dart';
import 'package:mentecart_app/features/services/data/service_api.dart';

import 'core/api/api_service.dart';

import 'features/auth/bloc/auth_bloc.dart';

import 'features/services/bloc/service_bloc.dart';

import 'features/splash/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [

        // Auth Bloc
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(ApiService()),
        ),

        // Service Bloc
        BlocProvider<ServiceBloc>(
          create: (_) => ServiceBloc(ServiceApi()),
        ),
        
        // Cart Bloc
        BlocProvider<CartBloc>(
  create: (_) => CartBloc(CartApi()),
),
   // BOOKING (IMPORTANT FOR CHECKOUT + PAYMENT FLOW)
      BlocProvider<BookingBloc>(
  create: (_) => BookingBloc(
    BookingApi(ApiService()),
  ),
),

      ],
      
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MenteCart',

        // Start from Splash
        home: const SplashScreen(),

        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
          ),
          useMaterial3: true,
        ),
      ),
    );
  }
}