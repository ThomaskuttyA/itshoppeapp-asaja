import 'package:flutter/material.dart';
import 'aboutus.dart';
import 'product_page.dart';
import 'shop_directory.dart';
import 'main.dart';
import 'messages.dart';
import 'notification.dart';
import 'dashboard.dart';

const darkBlue = Color(0xFF1E2B6D);

class FooterNavBar extends StatelessWidget {
  final String email;
  final int userId;
  final BuildContext parentContext;

  const FooterNavBar({
    super.key,
    required this.email,
    required this.userId,
    required this.parentContext,
  });

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
            _navIcon(Icons.home, () {
              Navigator.push(parentContext,
                  MaterialPageRoute(builder: (_) => const DashboardPage()));
            }),
            _navIcon(Icons.menu, () {
              Navigator.push(parentContext,
                  MaterialPageRoute(builder: (_) => const AboutUsPage()));
            }),
            _navIcon(Icons.store, () {
              Navigator.push(parentContext,
                  MaterialPageRoute(builder: (_) => const ShopDirectoryPage()));
            }),
            _navIcon(Icons.shopping_cart, () {
              Navigator.push(parentContext,
                  MaterialPageRoute(builder: (_) => ProductPage(
                    email: email,
                    userId: userId,
                  )));
            }),
            _navIcon(Icons.notifications, () {
              Navigator.push(parentContext,
                  MaterialPageRoute(builder: (_) => const NotificationPage()));
            }),
            _navIcon(Icons.message, () {
              Navigator.push(parentContext,
                  MaterialPageRoute(builder: (_) => const MessagesPage()));
            }),
            _navIcon(Icons.logout, () {
              Navigator.of(parentContext).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: Colors.white),
      onPressed: onTap,
    );
  }
}
