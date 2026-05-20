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
  bool _completed = false;

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

  void _setLoading(bool v) {
    if (!mounted) return;
    setState(() => isLoading = v);
  }

  void _finish(bool result, String message) {
    if (_completed) return;
    _completed = true;

    _setLoading(false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );

    if (result) {
      context.read<CartBloc>().add(ClearCartEvent());
      context.read<ServiceBloc>().add(FetchServicesEvent());
    }

    Navigator.pop(context, result);
  }

  void payWithCash() {
    _setLoading(true);
    context.read<BookingBloc>().add(PayCashEvent(widget.bookingId));
  }

  void cancelBooking() {
    _setLoading(true);
    context.read<BookingBloc>().add(CancelBookingEvent(widget.bookingId));
  }

  void showCardDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Enter Card Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: cardNameController),
              TextField(controller: cardNumberController),
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
        if (_completed) return;

        if (state is BookingPaymentSuccess) {
          _finish(true, "Booking Confirmed 🎉");
        }

        else if (state is BookingCancelSuccess) {
          _finish(false, "Booking Cancelled ❌");
        }

        else if (state is BookingError) {
          _finish(false, state.message ?? "");
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