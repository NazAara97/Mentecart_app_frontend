import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mentecart_app/features/booking/data/booking_api.dart';
import 'package:mentecart_app/core/api/api_service.dart';

import 'package:mentecart_app/features/cart/bloc/cart_bloc.dart';
import 'package:mentecart_app/features/cart/bloc/cart_event.dart';

import 'package:mentecart_app/features/services/bloc/service_bloc.dart';
import 'package:mentecart_app/features/services/bloc/service_event.dart';

import 'package:mentecart_app/features/services/home_screen.dart';

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
  final BookingApi api = BookingApi(ApiService());

  bool showCardForm = false;
  bool isLoading = false;

  final cardNameController = TextEditingController();
  final cardNumberController = TextEditingController();
  final expMonthController = TextEditingController();
  final expYearController = TextEditingController();

  /// ✅ COMMON SUCCESS HANDLER
  void handleSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );

    /// ✅ CLEAR CART
    context.read<CartBloc>().add(ClearCartEvent());

    /// ✅ REFRESH SERVICES
    context.read<ServiceBloc>().add(FetchServicesEvent());

    /// ✅ GO HOME
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  /// 💵 CASH PAYMENT
  Future<void> payCash() async {
    setState(() => isLoading = true);

    try {
      await api.payWithCash(widget.bookingId);
      handleSuccess("Cash booking confirmed");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cash payment failed")),
      );
    }

    setState(() => isLoading = false);
  }

  /// 💳 CARD PAYMENT
  Future<void> payCard() async {
    if (cardNameController.text.isEmpty ||
        cardNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter card details")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await api.payWithCard(
        bookingId: widget.bookingId,
        cardHolderName: cardNameController.text,
        cardNumber: cardNumberController.text,
        expiryMonth: expMonthController.text,
        expiryYear: expYearController.text,
      );

      handleSuccess("Card payment successful");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Card payment failed")),
      );
    }

    setState(() => isLoading = false);
  }

  /// ❌ CANCEL BOOKING
  Future<void> cancelBooking() async {
    setState(() => isLoading = true);

    try {
      await api.cancelBooking(widget.bookingId);
      handleSuccess("Booking cancelled successfully");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cancel failed")),
      );
    }

    setState(() => isLoading = false);
  }

  /// ⚠️ CONFIRM CANCEL DIALOG
  Future<void> confirmCancel() async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cancel Booking"),
        content: const Text("Are you sure you want to cancel this booking?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      cancelBooking();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),

      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                /// 💰 TOTAL
                Text(
                  "Total: Rs. ${widget.total.toStringAsFixed(0)}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                /// 💵 CASH
                ElevatedButton.icon(
                  icon: const Icon(Icons.money),
                  label: const Text("Pay with Cash"),
                  onPressed: isLoading ? null : payCash,
                ),

                const SizedBox(height: 12),

                /// 💳 CARD
                ElevatedButton.icon(
                  icon: const Icon(Icons.credit_card),
                  label: const Text("Pay with Card"),
                  onPressed: isLoading
                      ? null
                      : () {
                          setState(() {
                            showCardForm = !showCardForm;
                          });
                        },
                ),

                /// 💳 CARD FORM
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: showCardForm
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Column(
                    children: [
                      const SizedBox(height: 10),

                      TextField(
                        controller: cardNameController,
                        decoration: const InputDecoration(
                          labelText: "Card Holder Name",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: cardNumberController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Card Number",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: expMonthController,
                              decoration: const InputDecoration(
                                labelText: "MM",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: expYearController,
                              decoration: const InputDecoration(
                                labelText: "YY",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      ElevatedButton(
                        onPressed: isLoading ? null : payCard,
                        child: const Text("Confirm Card Payment"),
                      ),
                    ],
                  ),
                  secondChild: const SizedBox(),
                ),

                const SizedBox(height: 20),

                /// ❌ CANCEL BUTTON
                ElevatedButton.icon(
                  icon: const Icon(Icons.cancel),
                  label: const Text("Cancel Booking"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: isLoading ? null : confirmCancel,
                ),
              ],
            ),
          ),

          /// 🔄 LOADING
          if (isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}