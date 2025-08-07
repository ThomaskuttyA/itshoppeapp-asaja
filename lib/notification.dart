import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'dashboard.dart';
import 'shop_directory.dart';
import 'product_page.dart';
import 'aboutus.dart';
import 'messages.dart';
import 'main.dart';

// Notification model
class NotificationItem {
  final int id;
  final String title;
  final String message;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: int.parse(json['id'].toString()),
      title: json['title'],
      message: json['message'],
    );
  }
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<List<NotificationItem>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = fetchNotifications().then((notifications) {
      if (notifications.isNotEmpty) {
        _storeLastSeenNotificationId(notifications.first.id);
      }
      return notifications;
    });
  }

  Future<void> _storeLastSeenNotificationId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastSeenNotificationId', id);
  }

  Future<List<NotificationItem>> fetchNotifications() async {
    final url = Uri.parse('$baseUrl/get_notifications.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => NotificationItem.fromJson(json)).toList();
      } else {
        throw Exception('Server error or empty response.');
      }
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  Widget _navIcon(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: Colors.white),
      onPressed: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2B6D), // Dark blue
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF1E2B6D),
        foregroundColor: const Color(0xFFF65A06), // Orange
        elevation: 0,
      ),
      body: FutureBuilder<List<NotificationItem>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFF65A06)),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No notifications available.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          } else {
            final notifications = snapshot.data!;
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white24),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return Card(
                  color: const Color(0xFF2C3E91),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active, color: Color(0xFFF65A06)),
                    title: Text(
                      notif.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      notif.message,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              },
            );
          }
        },
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

              _navIcon(Icons.store, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ShopDirectoryPage()));
              }),
              _navIcon(Icons.notifications, () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const NotificationPage()));
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
    );
  }
}
