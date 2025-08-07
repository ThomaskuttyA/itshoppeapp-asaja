import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product_page.dart';
import 'constants.dart';
import 'package:lottie/lottie.dart';

const darkBlue = Color(0xFF1E2B6D);
const cardBlue = Color(0xFF2C3E91);
const orange = Color(0xFFF65A06);

class CartPage extends StatefulWidget {
  final Map<Product, int> cartItems;
  final int userId;
  final String username;

  const CartPage({
    Key? key,
    required this.cartItems,
    required this.userId,
    required this.username,
  }) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isOrdering = false;

  double get totalPrice {
    return widget.cartItems.entries
        .map((e) => e.key.price * e.value)
        .fold(0, (a, b) => a + b);
  }

  Future<void> _placeOrder() async {
    setState(() => _isOrdering = true);

    final url = Uri.parse('$baseUrl/save_order.php');
    final orderItems = widget.cartItems.entries.map((e) {
      return {
        'product_id': e.key.id,
        'quantity': e.value,
      };
    }).toList();

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': widget.userId,
          'username': widget.username,
          'items': orderItems,
          'total_amount': totalPrice,
        }),
      );

      final res = jsonDecode(response.body);
      if (res['success']) {
        setState(() {
          widget.cartItems.clear();
        });
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${res['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => _isOrdering = false);
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: darkBlue,
        title: const Text("Order Placed!", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/Success.json',
              width: 150,
              height: 150,
              repeat: false,
            ),
            const SizedBox(height: 12),
            const Text(
              "Your order was placed successfully.",
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to product page
            },
            child: const Text("OK", style: TextStyle(color: orange)),
          ),
        ],
      ),
    );
  }

  void _updateQuantity(Product product, int delta) {
    setState(() {
      int currentQty = widget.cartItems[product] ?? 0;
      int newQty = currentQty + delta;

      if (newQty <= 0) {
        widget.cartItems.remove(product);
      } else {
        widget.cartItems[product] = newQty;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        backgroundColor: darkBlue,
        foregroundColor: orange,
        title: const Text("Cart"),
      ),
      body: widget.cartItems.isEmpty
          ? const Center(
        child: Text(
          "Your cart is empty",
          style: TextStyle(color: Colors.white70),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final product = widget.cartItems.keys.elementAt(index);
                final quantity = widget.cartItems[product]!;

                return Card(
                  color: cardBlue,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(product.imageUrl),
                      backgroundColor: Colors.white24,
                      onBackgroundImageError: (_, __) {},
                      child: product.imageUrl.isEmpty
                          ? const Icon(Icons.broken_image, color: Colors.white54)
                          : null,
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "₹${product.price.toStringAsFixed(2)} x $quantity",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.white),
                              onPressed: () => _updateQuantity(product, -1),
                            ),
                            Text(
                              quantity.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: Colors.white),
                              onPressed: () => _updateQuantity(product, 1),
                            ),
                          ],
                        )
                      ],
                    ),
                    trailing: Text(
                      "₹${(product.price * quantity).toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Total: ₹${totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _isOrdering ? null : _placeOrder,
                    child: _isOrdering
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Place Order now",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
