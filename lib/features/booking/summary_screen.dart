import 'package:flutter/material.dart';

import 'package:mentecart_app/features/booking/payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List items;
  final DateTime selectedDateTime;
  final double total;
  final String bookingId; // ✅ FIXED (was missing but required conceptually)

  const CheckoutScreen({
    super.key,
    required this.items,
    required this.selectedDateTime,
    required this.total,
    required this.bookingId,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late DateTime selectedDateTime;

  @override
  void initState() {
    super.initState();
    selectedDateTime = widget.selectedDateTime;
  }

  String formatDateTime(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} "
        "${dateTime.hour.toString().padLeft(2, '0')}:"
        "${dateTime.minute.toString().padLeft(2, '0')}";
  }

  /// 🧮 TAX + TOTAL CALCULATION
  double get tax => widget.total * 0.03;
  double get grandTotal => widget.total + tax;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Booking Summary")),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Order Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            /// 🧾 ITEMS LIST
            Expanded(
              child: ListView.builder(
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];

                  final service = item.service;
                  final qty = item.quantity;

                  return Card(
                    child: ListTile(
                      title: Text(service.title),
                      subtitle: Text("Qty: $qty"),
                      trailing: Text(
                        "Rs. ${(service.price * qty).toStringAsFixed(0)}",
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            /// 📅 DATE & TIME
            Card(
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text("Appointment Date & Time"),
                subtitle: Text(formatDateTime(selectedDateTime)),
                trailing: TextButton(
                  child: const Text("Change"),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDateTime,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );

                    if (date == null) return;

                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                    );

                    if (time == null) return;

                    setState(() {
                      selectedDateTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// 💰 TOTAL SECTION
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Subtotal: Rs. ${widget.total.toStringAsFixed(0)}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Tax (3%): Rs. ${tax.toStringAsFixed(0)}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Divider(),
                    Text(
                      "Total: Rs. ${grandTotal.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// 💳 BUTTON → GO TO PAYMENT
            SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: () {
     Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => PaymentScreen(
      bookingId: widget.bookingId,
      total: grandTotal,
      items: widget.items,
      dateTime: selectedDateTime,
    ),
  ),
);
    },
    child: const Text("Proceed Payment"),
  ),
),
          ],
        ),
      ),
    );
  }
}