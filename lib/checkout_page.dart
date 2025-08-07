import 'package:flutter/material.dart';
import 'product_page.dart';
import 'constants.dart';

class CheckoutPage extends StatefulWidget {
  final Map<Product, int> cartItems;

  const CheckoutPage({Key? key, required this.cartItems}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late Map<Product, int> _items;

  @override
  void initState() {
    super.initState();
    _items = Map.from(widget.cartItems);
  }

  void _increaseQuantity(Product product) {
    setState(() {
      _items[product] = (_items[product] ?? 1) + 1;
    });
  }

  void _decreaseQuantity(Product product) {
    setState(() {
      final currentQty = _items[product] ?? 1;
      if (currentQty > 1) {
        _items[product] = currentQty - 1;
      } else {
        _items.remove(product);
      }
    });
  }

  double get totalPrice {
    double total = 0;
    _items.forEach((product, qty) {
      total += product.price * qty;
    });
    return total;
  }

  void _placeOrder() {
    // TODO: connect to your backend API or WhatsApp order here
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Order Placed!"),
        content: Text("Total amount: ₹${totalPrice.toStringAsFixed(2)}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context, _items); // go back to previous page with updated cart
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Checkout")),
        body: const Center(child: Text("Your cart is empty")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final product = _items.keys.elementAt(index);
                final quantity = _items[product]!;
                return ListTile(
                  leading: Image.network(
                    product.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                  ),
                  title: Text(product.name),
                  subtitle: Text("₹${product.price} x $quantity"),
                  trailing: SizedBox(
                    width: 120,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => _decreaseQuantity(product),
                        ),
                        Text(quantity.toString()),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => _increaseQuantity(product),
                        ),
                      ],
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
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _placeOrder,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        "Place Order",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
