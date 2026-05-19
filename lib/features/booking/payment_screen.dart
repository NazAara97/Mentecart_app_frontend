import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mentecart_app/features/booking/bloc/book_bloc.dart';
import 'package:mentecart_app/features/booking/bloc/book_event.dart';
import 'package:mentecart_app/features/booking/bloc/book_state.dart';

import 'package:mentecart_app/features/cart/bloc/cart_bloc.dart';
import 'package:mentecart_app/features/cart/bloc/cart_event.dart';

import 'package:mentecart_app/features/services/bloc/service_bloc.dart';
import 'package:mentecart_app/features/services/bloc/service_event.dart';

class PaymentScreen extends StatefulWidget {
  final String bookingId;
  final double total;
  final List items;
  final DateTime dateTime;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.total,
    required this.items,
    required this.dateTime,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isPaying = false;
  bool isCancelling = false;

  final cardNameController = TextEditingController();
  final cardNumberController = TextEditingController();
  final expiryMonthController = TextEditingController();
  final expiryYearController = TextEditingController();

  void payNow() {
    context.read<BookingBloc>().add(
          PayBookingEvent(
            bookingId: widget.bookingId,
            method: "card",
            transactionId:
                DateTime.now().millisecondsSinceEpoch.toString(),
            cardHolderName: cardNameController.text,
            cardNumber: cardNumberController.text,
            expiryMonth: expiryMonthController.text,
            expiryYear: expiryYearController.text,
          ),
        );
  }

  void cancelBooking() {
    context.read<BookingBloc>().add(
      CancelBookingEvent(widget.bookingId),
    );
  }

  void _goHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home_screen.dart',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) async {

        /// ✅ PAYMENT SUCCESS
        if (state is BookingPaymentSuccess) {
          if (!mounted) return;

          setState(() => isPaying = false);

          context.read<CartBloc>().add(ClearCartEvent());
          context.read<ServiceBloc>().add(FetchServicesEvent());

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Booking Confirmed 🎉")),
          );

          _goHome();
        }

        /// ❌ CANCEL SUCCESS
        if (state is BookingCancelSuccess) {
          if (!mounted) return;

          setState(() => isCancelling = false);

          context.read<CartBloc>().add(ClearCartEvent());
          context.read<ServiceBloc>().add(FetchServicesEvent());

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Booking Cancelled ❌")),
          );

          _goHome();
        }

        /// ⚠ ERROR
        if (state is BookingError) {
          if (!mounted) return;

          setState(() {
            isPaying = false;
            isCancelling = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },

      child: Scaffold(
        appBar: AppBar(title: const Text("Payment")),

        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text("Booking ID: ${widget.bookingId}"),
              Text("Total: Rs. ${widget.total.toStringAsFixed(0)}"),

              const SizedBox(height: 20),

              TextField(
                controller: cardNameController,
                decoration: const InputDecoration(
                  labelText: "Card Holder Name",
                ),
              ),

              TextField(
                controller: cardNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Card Number",
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: expiryMonthController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "MM"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: expiryYearController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "YYYY"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// PAY BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isPaying
                      ? null
                      : () {
                          setState(() => isPaying = true);
                          payNow();
                        },
                  child: isPaying
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Pay Now"),
                ),
              ),

              const SizedBox(height: 10),

              /// CANCEL BUTTON
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: isCancelling
                      ? null
                      : () {
                          setState(() => isCancelling = true);
                          cancelBooking();
                        },
                  child: isCancelling
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Cancel Booking"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}