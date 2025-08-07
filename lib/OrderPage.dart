import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'constants.dart';

class Order {
  final int orderId;
  final double totalAmount;
  final String orderDate;
  final String orderStatus;
  final String deliveryStatus;
  final String dispatchedMethod;
  final String trackingId;
  final List<OrderItem> products;

  Order({
    required this.orderId,
    required this.totalAmount,
    required this.orderDate,
    required this.orderStatus,
    required this.deliveryStatus,
    required this.dispatchedMethod,
    required this.trackingId,
    required this.products,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final productsJson = json['products'] as List<dynamic>;
    List<OrderItem> productsList = productsJson.map((p) => OrderItem.fromJson(p)).toList();

    return Order(
      orderId: json['order_id'],
      totalAmount: double.parse(json['total_price'].toString()),
      orderDate: json['created_at'],
      orderStatus: json['order_status'] ?? 'Pending',
      deliveryStatus: json['delivery_status'] ?? 'Pending',
      dispatchedMethod: json['dispatched_method'] ?? '',
      trackingId: json['tracking_id'] ?? '',
      products: productsList,
    );
  }
}

class OrderItem {
  final int id;
  final String name;
  final String imageUrl;
  final double price;
  final int quantity;

  OrderItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
      price: double.parse(json['price'].toString()),
      quantity: json['quantity'],
    );
  }
}

class OrderPage extends StatefulWidget {
  final int userId;
  final String username;

  const OrderPage({Key? key, required this.userId, required this.username}) : super(key: key);

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with TickerProviderStateMixin {
  late Future<List<Order>> _ordersFuture;
  final List<String> statusSteps = ['ordered', 'accepted', 'dispatched', 'delivered'];

  @override
  void initState() {
    super.initState();
    _ordersFuture = fetchOrders(widget.userId);
  }

  Future<List<Order>> fetchOrders(int userId) async {
    final url = Uri.parse('$baseUrl/get_orders.php?user_id=$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final ordersJson = data['orders'] as List;
        return ordersJson.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load orders: ${data['message']}');
      }
    } else {
      throw Exception('Failed to load orders from server');
    }
  }

  Color getColorForStep(int stepIndex, int currentStepIndex) {
    return stepIndex <= currentStepIndex ? Colors.orange : Colors.white54;
  }

  Icon getIconForStep(int stepIndex, int currentStepIndex) {
    if (stepIndex < currentStepIndex) {
      return const Icon(Icons.check_circle, color: Colors.orange);
    } else if (stepIndex == currentStepIndex) {
      return const Icon(Icons.radio_button_checked, color: Colors.orange);
    } else {
      return const Icon(Icons.radio_button_unchecked, color: Colors.white54);
    }
  }

  Widget buildStatusTracker(String orderStatus) {
    final statusLower = orderStatus.toLowerCase();
    int currentStepIndex = statusSteps.indexOf(statusLower);
    if (currentStepIndex == -1) currentStepIndex = 0;

    List<Widget> widgets = [];

    for (int i = 0; i < statusSteps.length; i++) {
      final isCurrent = i == currentStepIndex;

      widgets.add(Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCurrent ? Colors.orange.withOpacity(0.15) : Colors.transparent,
            ),
            child: isCurrent
                ? TweenAnimationBuilder<double>(
              tween: Tween(begin: 1.0, end: 1.2),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: getIconForStep(i, currentStepIndex),
                );
              },
              onEnd: () => setState(() {}),
            )
                : getIconForStep(i, currentStepIndex),
          ),
          const SizedBox(height: 4),
          Text(
            statusSteps[i][0].toUpperCase() + statusSteps[i].substring(1),
            style: TextStyle(
              color: getColorForStep(i, currentStepIndex),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ));

      if (i != statusSteps.length - 1) {
        widgets.add(Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 30,
          height: 2,
          color: i < currentStepIndex ? Colors.orange : Colors.white54,
        ));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widgets,
    );
  }

  Widget statusChip(String status) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'pending':
        chipColor = Colors.grey;
        break;
      case 'accepted':
        chipColor = Colors.blue;
        break;
      case 'dispatched':
        chipColor = Colors.orange;
        break;
      case 'delivered':
        chipColor = Colors.green;
        break;
      case 'rejected':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }
    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: chipColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF1E2B6D);
    const cardBlue = Color(0xFF2C3E91);
    const orange = Color(0xFFF65A06);

    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        title: Text('Orders - ${widget.username}'),
        backgroundColor: darkBlue,
        foregroundColor: orange,
        elevation: 0,
      ),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: orange));
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No orders found', style: TextStyle(color: Colors.white70)),
            );
          } else {
            final orders = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  color: cardBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ExpansionTile(
                    iconColor: orange,
                    collapsedIconColor: orange,
                    title: Text(
                      'Order #${order.orderId} - ₹${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.orderDate, style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 6),
                        buildStatusTracker(order.orderStatus),
                      ],
                    ),
                    children: [
                      if (order.orderStatus.toLowerCase() == 'delivered')
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Lottie.asset(
                              'assets/animations/Success.json',
                              width: 150,
                              height: 150,
                              repeat: false,
                            ),
                          ),
                        ),

                      ...order.products.map((item) {
                        final imageUrl = item.imageUrl.startsWith('/')
                            ? '$baseUrl${item.imageUrl}'
                            : '$baseUrl/${item.imageUrl}';

                        return ListTile(
                          leading: item.imageUrl.isNotEmpty
                              ? Image.network(
                            imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                              : const SizedBox(width: 50, height: 50),
                          title: Text(item.name, style: const TextStyle(color: Colors.white)),
                          subtitle: Text(
                            'Quantity: ${item.quantity}  |  Price: ₹${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        );
                      }).toList(),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(color: Colors.white24),
                            Row(
                              children: [
                                const Text("Order Status: ", style: TextStyle(color: Colors.white70)),
                                statusChip(order.orderStatus),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Delivery Status: ${order.deliveryStatus}',
                                style: const TextStyle(color: Colors.white70)),

                            if (order.deliveryStatus.toLowerCase() == 'dispatched') ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.local_shipping, color: Colors.orange),
                                  const SizedBox(width: 8),
                                  Text('Dispatch Method: ${order.dispatchedMethod}',
                                      style: const TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.confirmation_num, color: Colors.orange),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Tracking ID: ${order.trackingId}',
                                      style: const TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
