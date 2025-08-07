import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

import 'cart_page.dart';
import 'orderpage.dart';
import 'dashboard.dart';
import 'aboutus.dart';
import 'shop_directory.dart';
import 'notification.dart';
import 'messages.dart';
import 'main.dart';

const darkBlue = Color(0xFF1E2B6D);
const cardBlue = Color(0xFF2C3E91);
const orange = Color(0xFFF65A06);

class Product {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final int quantity;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['name'],
    price: (json['price'] as num).toDouble(),
    imageUrl: json['image_url'],
    quantity: json['quantity'],
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Product && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

class ProductPage extends StatefulWidget {
  final String email;
  final int userId;

  const ProductPage({
    Key? key,
    required this.email,
    required this.userId,
  }) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage>
    with SingleTickerProviderStateMixin {
  final String _imageBaseUrl = 'https://itshoppe.in/itshoppe_app_api/';
  //final String _imageBaseUrl = 'https://itshoppe.in/itshoppe_app_api/';

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  final Map<Product, int> _cart = {};
  bool _isLoading = false;
  String _searchTerm = '';
  final TextEditingController _searchController = TextEditingController();
  bool _showAddAnimation = false;

  // For flash notification
  String? _flashMessage;
  late AnimationController _flashController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    fetchProducts();

    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1), // start hidden above top
      end: const Offset(0, 0), // visible position
    ).animate(CurvedAnimation(parent: _flashController, curve: Curves.easeInOut));

    // Simulate new notification arrival every 15 seconds (for demo)
    Future.delayed(const Duration(seconds: 15), _simulateNewNotification);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  Future<void> fetchProducts() async {
    setState(() => _isLoading = true);
    final url = Uri.parse('https://itshoppe.in/itshoppe_app_api/products.php');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List<Product> loaded =
        (data['products'] as List).map((e) => Product.fromJson(e)).toList();
        setState(() {
          _products = loaded;
          _filteredProducts = loaded;
        });
      }
    } catch (e) {
      debugPrint('Product fetch error: $e');
    }
    setState(() => _isLoading = false);
  }

  void _applySearch(String searchTerm) {
    _searchTerm = searchTerm.toLowerCase();
    setState(() {
      _filteredProducts = _products
          .where((product) => product.name.toLowerCase().contains(_searchTerm))
          .toList();
    });
  }

  void _addToCart(Product p) {
    setState(() {
      _cart[p] = (_cart[p] ?? 0) + 1;
      _showAddAnimation = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _showAddAnimation = false);
      }
    });
  }

  void _goToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartPage(
          cartItems: _cart,
          userId: widget.userId,
          username: widget.email,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  void _goToOrders() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderPage(
          userId: widget.userId,
          username: widget.email,
        ),
      ),
    );
  }

  int get _cartCount => _cart.values.fold(0, (sum, q) => sum + q);

  void _simulateNewNotification() {
    showNotificationFlash('New notification received!');
    // schedule next simulated notification
    Future.delayed(const Duration(seconds: 30), _simulateNewNotification);
  }

  void showNotificationFlash(String message) {
    setState(() {
      _flashMessage = message;
    });
    _flashController.forward();

    // Hide banner automatically after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _flashController.reverse().then((_) {
          setState(() {
            _flashMessage = null;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: darkBlue,
          appBar: AppBar(
            backgroundColor: darkBlue,
            foregroundColor: orange,
            title: const Text('Products'),
            actions: [
              IconButton(
                icon: const Icon(Icons.list_alt),
                tooltip: 'Orders',
                onPressed: _goToOrders,
              ),
              Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: _goToCart,
                  ),
                  if (_cartCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$_cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              )
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator(color: orange))
              : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  onChanged: _applySearch,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon:
                    const Icon(Icons.search, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount;
                    double width = constraints.maxWidth;

                    if (width < 600) {
                      crossAxisCount = 2;
                    } else if (width < 900) {
                      crossAxisCount = 3;
                    } else {
                      crossAxisCount = 4;
                    }

                    return _filteredProducts.isEmpty
                        ? const Center(
                      child: Text(
                        'No products found',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                        : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _filteredProducts.length,
                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.7,
                      ),
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return _buildProductCard(product);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // _navIcon(Icons.home, () {
                  //   Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //           builder: (context) => const DashboardPage()));
                  // }),
                  _navIcon(Icons.store, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ShopDirectoryPage()));
                  }),
                  _navIcon(Icons.notifications, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NotificationPage()));
                  }),
                  _navIcon(Icons.message, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MessagesPage()));
                  }),
                  _navIcon(Icons.logout, () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                          (route) => false,
                    );
                  }),
                ],
              ),
            ),
          ),
        ),

        // Flash Notification Banner at top
        if (_flashMessage != null)
          SlideTransition(
            position: _slideAnimation,
            child: Container(
              width: double.infinity,
              color: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: SafeArea(
                bottom: false,
                child: Text(
                  _flashMessage!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

        // Add-to-cart animation overlay
        if (_showAddAnimation)
          Positioned.fill(
            child: Container(
              color: Colors.black45,
              alignment: Alignment.center,
              child: Card(
                color: Colors.black87,
                elevation: 12,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset(
                        'assets/animations/cart.json',
                        width: 150,
                        height: 150,

                        repeat: false,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text(
                            'Failed to load animation',
                            style: TextStyle(color: Colors.white),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Item added to cart',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductCard(Product p) {
    final String fullImageUrl = _imageBaseUrl + p.imageUrl;

    return Stack(
      children: [
        Card(
          color: cardBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Expanded(
                child: Image.network(
                  fullImageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image, color: Colors.white70),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '₹${p.price.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: p.quantity > 0 ? () => _addToCart(p) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: p.quantity > 0 ? orange : Colors.grey,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Add to Cart'),
                    )
                  ],
                ),
              )
            ],
          ),
        ),

        // Out of Stock Badge overlay
        if (p.quantity == 0)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: -0.4, // slight diagonal tilt
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.shade900.withOpacity(0.7),
                        blurRadius: 10,
                        offset: const Offset(3, 3),
                      )
                    ],
                  ),
                  child: const Text(
                    'OUT OF STOCK',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _navIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }
}
