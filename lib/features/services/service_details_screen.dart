import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mentecart_app/features/cart/cart_screen.dart';
import 'package:mentecart_app/features/cart/data/cart_api.dart';
import 'package:mentecart_app/features/services/bloc/service_bloc.dart';
import 'package:mentecart_app/features/services/bloc/service_event.dart';
import 'package:mentecart_app/features/services/bloc/service_state.dart';


class ServiceDetailScreen extends StatefulWidget {
  final String serviceId;

  const ServiceDetailScreen({
    super.key,
    required this.serviceId,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  bool isAdding = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<ServiceBloc>().add(
        FetchServiceByIdEvent(widget.serviceId),
      );
    });
  }

  Future<void> addToCart(String serviceId) async {
    setState(() => isAdding = true);

    try {
      await CartApi().addToCart(serviceId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Added to cart")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }

    setState(() => isAdding = false);
  }

  void goToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CartScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Detail"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: goToCart,
          )
        ],
      ),

      body: BlocBuilder<ServiceBloc, ServiceState>(
        builder: (context, state) {

          /// ⏳ LOADING
          if (state is ServiceDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          /// ❌ ERROR
          if (state is ServiceDetailError) {
            return Center(child: Text(state.message));
          }

          /// ✅ LOADED
          if (state is ServiceDetailLoaded) {
            final service = state.service;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// 🖼 IMAGE (optional)
                    if (service.image != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          service.image!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                    const SizedBox(height: 16),

                    /// 📦 CARD
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            /// TITLE
                            Text(
                              service.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            /// DESCRIPTION
                            Text(
                              service.description,
                              style: const TextStyle(fontSize: 16),
                            ),

                            const SizedBox(height: 16),

                            /// PRICE
                            Text(
                              "Rs ${service.price}",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// 🛒 ADD TO CART
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isAdding
                            ? null
                            : () => addToCart(service.id),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: isAdding
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Add to Cart",
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// 🚀 GO TO CART BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: goToCart,
                        child: const Text("Go to Cart"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}