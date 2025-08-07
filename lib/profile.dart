import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';

// Theme colors
const darkBlue = Color(0xFF1E2B6D);
const orange = Color(0xFFF65A06);

class ProfilePage extends StatefulWidget {
  final int userId;

  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? user;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final url = Uri.parse('$baseUrl/profile.php?user_id=${widget.userId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            user = data['user'];
            isLoading = false;
          });
        } else {
          setState(() {
            error = data['message'];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          error = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  String formatDate(String dob) {
    try {
      final date = DateTime.parse(dob);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return dob;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: darkBlue,
        body: Center(child: CircularProgressIndicator(color: orange)),
      );
    }

    if (error != null) {
      return Scaffold(
        backgroundColor: darkBlue,
        appBar: AppBar(
          backgroundColor: darkBlue,
          foregroundColor: orange,
          title: const Text('Profile'),
        ),
        body: Center(
          child: Text(
            error!,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        backgroundColor: darkBlue,
        foregroundColor: orange,
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.white12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: orange,
                  child: Icon(Icons.person, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 20),
                profileItem(Icons.confirmation_number, "User ID", user!['id'].toString()),
                profileItem(Icons.badge, "Full Name", user!['fullname']),
                profileItem(Icons.calendar_today, "Date of Birth", formatDate(user!['dob'])),
                profileItem(Icons.phone, "Phone", user!['phone']),
                profileItem(Icons.email, "Email", user!['email']),
                profileItem(Icons.person_outline, "Username", user!['username']),
                profileItem(Icons.location_on, "Place", user!['place']),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget profileItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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
