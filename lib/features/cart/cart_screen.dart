import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mentecart_app/features/cart/bloc/cart_bloc.dart';
import 'package:mentecart_app/features/cart/bloc/cart_event.dart';
import 'package:mentecart_app/features/cart/bloc/cart_state.dart';

import 'package:mentecart_app/features/booking/data/booking_api.dart';
import 'package:mentecart_app/core/api/api_service.dart';

import 'package:mentecart_app/features/booking/summary_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<CartBloc>().add(FetchCartEvent());
    });
  }

  double getSubtotal(List items) {
    double total = 0;
    for (final item in items) {
      total += item.service.price * item.quantity;
    }
    return total;
  }

  double getTax(double subtotal) => subtotal * 0.03;

  double getTotal(List items) {
    final subtotal = getSubtotal(items);
    return subtotal + getTax(subtotal);
  }

  /// ✅ UPDATED CHECKOUT (NO GLOBAL DATE)
  Future<void> proceedCheckout(List items) async {
  setState(() => isLoading = true);

  try {
    final bookingApi = BookingApi(ApiService());

    DateTime appointmentDate;

    try {
      appointmentDate = DateTime.parse(
        "${items.first.date}T${items.first.time}",
      );
    } catch (e) {
      appointmentDate = DateTime.now();
    }

    final booking = await bookingApi.checkout(
      appointmentDate,
      items,
    );

    print("BOOKING SAVED: $booking");

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          items: items,
          total: (booking["totalAmount"] ?? 0).toDouble(),
          bookingId: booking["_id"],
        ),
      ),
    );

   
  } catch (e) {
    print("CHECKOUT ERROR: $e");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Checkout failed")),
    );
  } finally {
    if (mounted) setState(() => isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Cart")),

      body: BlocListener<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },

        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state is CartLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CartError) {
              return Center(child: Text(state.message));
            }

            if (state is! CartLoaded) {
              return const SizedBox();
            }

            final items = state.cart.items;

            if (items.isEmpty) {
              return const Center(child: Text("Your cart is empty"));
            }

            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                /// ❌ REMOVED GLOBAL DATE CARD

                ...items.map((item) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.service.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(item.service.description),

                          const SizedBox(height: 10),

                          /// ✅ SHOW ITEM DATE & TIME
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 16),
                              const SizedBox(width: 6),
                              Text("${item.date} at ${item.time}"),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Text("Price: Rs. ${item.service.price}"),
                          Text(
                            "Total: Rs. ${(item.service.price * item.quantity).toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: item.quantity > 1
                                        ? () {
                                            context.read<CartBloc>().add(
                                                  UpdateCartItemEvent(
                                                    item.id,
                                                    item.quantity - 1,
                                                    item.service.id,
                                                  ),
                                                );
                                          }
                                        : null,
                                  ),
                                  Text("${item.quantity}"),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      context.read<CartBloc>().add(
                                            UpdateCartItemEvent(
                                              item.id,
                                              item.quantity + 1,
                                              item.service.id,
                                            ),
                                          );
                                    },
                                  ),
                                ],
                              ),

                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  context.read<CartBloc>().add(
                                        RemoveCartItemEvent(item.id),
                                      );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),

      /// 💳 BOTTOM BAR
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is! CartLoaded) {
            return const SizedBox();
          }

          final items = state.cart.items;
          final total = getTotal(items);

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(blurRadius: 10, color: Colors.black12),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total: Rs. ${total.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                ElevatedButton(
                  onPressed: isLoading ? null : () => proceedCheckout(items),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Proceed"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}