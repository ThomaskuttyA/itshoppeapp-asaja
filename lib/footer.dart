import 'package:flutter/material.dart';
import 'aboutus.dart';
import 'product_page.dart';
import 'shop_directory.dart';
import 'main.dart';
import 'messages.dart';
import 'notification.dart';
import 'dashboard.dart';

const darkBlue = Color(0xFF1E2B6D);

class FooterBar extends StatelessWidget {
  final String email;
  final int userId;

  const FooterBar({super.key, required this.email, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            _navIcon(context, Icons.home, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardPage()));
            }),
            _navIcon(context, Icons.menu, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsPage()));
            }),
            _navIcon(context, Icons.store, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopDirectoryPage()));
            }),
            _navIcon(context, Icons.shopping_cart, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProductPage(email: email, userId: userId)));
            }),
            _navIcon(context, Icons.notifications, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPage()));
            }),
            _navIcon(context, Icons.message, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagesPage()));
            }),
            _navIcon(context, Icons.logout, () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(BuildContext context, IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: Colors.white),
      onPressed: onTap,
    );
  }
}
