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

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.total,
    required this.items,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isLoading = false;

  final cardNameController = TextEditingController();
  final cardNumberController = TextEditingController();
  final expiryMonthController = TextEditingController();
  final expiryYearController = TextEditingController();

  @override
  void dispose() {
    cardNameController.dispose();
    cardNumberController.dispose();
    expiryMonthController.dispose();
    expiryYearController.dispose();
    super.dispose();
  }

  void _setLoading(bool value) {
    if (!mounted) return;
    setState(() => isLoading = value);
  }

  void _successAndExit(String message) {
    context.read<CartBloc>().add(ClearCartEvent());
    context.read<ServiceBloc>().add(FetchServicesEvent());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );

    // return SUCCESS to CheckoutScreen
    Navigator.pop(context, true);
  }

  void _failAndExit() {
    Navigator.pop(context, false);
  }

  /// 💵 CASH PAYMENT
  void payWithCash() {
    _setLoading(true);

    context.read<BookingBloc>().add(
          PayCashEvent(widget.bookingId),
        );
  }

  /// ❌ CANCEL BOOKING
  void cancelBooking() {
    _setLoading(true);

    context.read<BookingBloc>().add(
          CancelBookingEvent(widget.bookingId),
        );
  }

  /// 💳 CARD PAYMENT DIALOG
  void showCardDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Enter Card Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cardNameController,
                decoration: const InputDecoration(labelText: "Card Holder"),
              ),
              TextField(
                controller: cardNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Card Number"),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: expiryMonthController,
                      decoration: const InputDecoration(labelText: "MM"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: expiryYearController,
                      decoration: const InputDecoration(labelText: "YYYY"),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                _setLoading(true);

                context.read<BookingBloc>().add(
                      PayCardEvent(
                        bookingId: widget.bookingId,
                        cardHolderName: cardNameController.text.isEmpty
                            ? "Unknown"
                            : cardNameController.text,
                        cardNumber: cardNumberController.text.isEmpty
                            ? "0000"
                            : cardNumberController.text,
                        expiryMonth: expiryMonthController.text.isEmpty
                            ? "00"
                            : expiryMonthController.text,
                        expiryYear: expiryYearController.text.isEmpty
                            ? "0000"
                            : expiryYearController.text,
                      ),
                    );
              },
              child: const Text("Pay"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        _setLoading(false);

        /// ✅ SUCCESS
        if (state is BookingPaymentSuccess) {
          _successAndExit("Booking Confirmed 🎉");
        }

        /// ❌ CANCEL SUCCESS
        if (state is BookingCancelSuccess) {
          _successAndExit("Booking Cancelled ❌");
        }

        /// ⚠ ERROR (IMPORTANT FIX FOR NULL ISSUE)
        if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message ?? "Something went wrong")),
          );

          _failAndExit();
        }
      },

      child: Scaffold(
        appBar: AppBar(
          title: const Text("Payment"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
        ),

        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text("Booking ID: ${widget.bookingId}"),
              Text("Total: Rs. ${widget.total.toStringAsFixed(0)}"),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: isLoading ? null : payWithCash,
                child: const Text("Pay With Cash"),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: isLoading ? null : showCardDialog,
                child: const Text("Pay With Card"),
              ),

              const SizedBox(height: 10),

              OutlinedButton(
                onPressed: isLoading ? null : cancelBooking,
                child: const Text("Cancel Booking"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}