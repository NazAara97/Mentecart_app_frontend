import 'package:flutter/material.dart';
import 'package:mentecart_app/features/booking/payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List items;
  final double total;
  final String bookingId;

  const CheckoutScreen({
    super.key,
    required this.items,
    required this.total,
    required this.bookingId,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {

  /// 🧮 TAX + TOTAL CALCULATION
  double get tax => widget.total * 0.03;
  double get grandTotal => widget.total + tax;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Summary"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
      ),
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

            /// 🧾 ITEMS LIST (WITH DATE & TIME)
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
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Qty: $qty"),
                          Text("Date: ${item.date}"),
                          Text("Time: ${item.time}"),
                        ],
                      ),
                      trailing: Text(
                        "Rs. ${(service.price * qty).toStringAsFixed(0)}",
                      ),
                    ),
                  );
                },
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
                        items: widget.items
                       
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