import 'package:flutter/material.dart';
import 'aboutus.dart';
import 'product_page.dart';
import 'shop_directory.dart';
import 'main.dart';
import 'profile.dart';
import 'messages.dart';
import 'notification.dart';
import 'dashboard.dart';
import 'package:lottie/lottie.dart';

const darkBlue = Color(0xFF1E2B6D);
const orange = Color(0xFFF65A06);

class HomePage extends StatefulWidget {
  final String? email;
  final int? userId;

  const HomePage({super.key, this.email, this.userId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget _navIcon(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: Colors.white),
      onPressed: onTap,
      tooltip: icon.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> buttons = [
      {'icon': Icons.home, 'label': 'Home', 'page': const DashboardPage()},
      {'icon': Icons.info, 'label': 'About Us', 'page': const AboutUsPage()},
      {'icon': Icons.store, 'label': 'Shop Directory', 'page': const ShopDirectoryPage()},
      {
        'icon': Icons.shopping_cart,
        'label': 'Merchandise',
        'page': ProductPage(email: widget.email ?? '', userId: widget.userId ?? 0)
      },
      {'icon': Icons.notifications, 'label': 'Notifications', 'page': const NotificationPage()},
      {'icon': Icons.message, 'label': 'Messages', 'page': const MessagesPage()},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkBlue,
        title: Row(
          children: [
            Image.asset(
              'assets/itlogo.png',
              height: 60,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: orange),
            tooltip: 'Profile',
            onPressed: () {
              if (widget.userId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(userId: widget.userId!),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User ID not available')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: orange),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      backgroundColor: orange,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          /// 🎉 Animated Welcome Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: Lottie.asset(
                      'assets/animations/Userhead.json',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'Hi, ${widget.email ?? 'Guest'}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          /// 🔲 Grid Menu
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: buttons.map((item) {
                return _buildHoverButton(
                  icon: item['icon'],
                  label: item['label'],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => item['page']),
                    );
                  },
                );
              }).toList(),
            ),
          ),

          /// 🚪 Footer Logout Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: darkBlue,
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
                  _navIcon(Icons.home, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardPage()));
                  }),
                  _navIcon(Icons.store, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ShopDirectoryPage()));
                  }),
                  _navIcon(Icons.shopping_cart, () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ProductPage(email: widget.email ?? '', userId: widget.userId ?? 0),
                    ));
                  }),
                  _navIcon(Icons.notifications, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationPage()));
                  }),
                  _navIcon(Icons.message, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MessagesPage()));
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
        ],
      ),
    );
  }

  Widget _buildHoverButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      onEnter: (_) => setState(() {}),
      onExit: (_) => setState(() {}),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: darkBlue,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: orange,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
