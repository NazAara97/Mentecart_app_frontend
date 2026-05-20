import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mentecart_app/features/cart/bloc/cart_bloc.dart';
import 'package:mentecart_app/features/cart/bloc/cart_event.dart';
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
  State<ServiceDetailScreen> createState() =>
      _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  bool isAdding = false;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<ServiceBloc>().add(
            FetchServiceByIdEvent(widget.serviceId),
          );
    });
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> pickTime() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a date first"),
        ),
      );
      return;
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  String get formattedDate {
    if (selectedDate == null) return "Select Date";
    return "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
  }

  String get formattedTime {
    if (selectedTime == null) return "Select Time";
    final hour = selectedTime!.hour.toString().padLeft(2, '0');
    final minute = selectedTime!.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  Future<void> addToCart(String serviceId) async {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Please select date and time"),
        ),
      );
      return;
    }

    setState(() => isAdding = true);

    try {
      await CartApi().addToCart(
        serviceId,
        selectedDate!,
        selectedTime!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Added to cart")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }

    if (mounted) {
      setState(() => isAdding = false);
    }
  }

  void goToCart() {
     context.read<CartBloc>().add(FetchCartEvent());
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CartScreen(

        ),

      ),
    );
  }

  void handleBack() {
    context.read<ServiceBloc>().add(FetchServicesEvent());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.read<ServiceBloc>().add(FetchServicesEvent());
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Service Detail"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: handleBack,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: goToCart,
            ),
          ],
        ),
        body: BlocBuilder<ServiceBloc, ServiceState>(
          builder: (context, state) {
            if (state is ServiceDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ServiceDetailError) {
              return Center(child: Text(state.message));
            }

            if (state is ServiceDetailLoaded) {
              final service = state.service;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              Text(
                                service.title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                service.description,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 16),
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

                      const SizedBox(height: 20),

                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: Text(formattedDate),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: pickDate,
                        ),
                      ),

                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.access_time),
                          title: Text(formattedTime),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: pickTime,
                        ),
                      ),

                      const SizedBox(height: 30),

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
      ),
    );
  }
}