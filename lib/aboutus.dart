import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dashboard.dart';           // Make sure to import your pages
          // If needed (or remove if circular)
import 'shop_directory.dart';
import 'product_page.dart';
import 'homepage.dart';
import 'messages.dart';
import 'main.dart';
import 'notification.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  Widget sectionTitle(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFFF65A06), // orange
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget sectionBody(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 16,
        height: 1.5,
      ),
    );
  }

  Widget _navIcon(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: Colors.white),
      onPressed: onTap,
      tooltip: icon.codePoint.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFF65A06);
    const blue = Color(0xFF1E2B6D);
    const darkBlue = Color(0xFF123456); // example dark blue for footer, change as needed

    return Scaffold(
      backgroundColor: blue,
      appBar: AppBar(
        backgroundColor: blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: orange),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        title: const Text(
          'About Us',
          style: TextStyle(
            color: orange,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  sectionBody(
                    'IT Shopee is your one-stop digital destination for all tech-related products. We bring innovation, affordability, and customer satisfaction together to provide the best online shopping experience.',
                  ),
                  const SizedBox(height: 24),
                  sectionTitle('AKITDA Initiative'),
                  const SizedBox(height: 12),
                  sectionBody(
                    'IT Shoppe is an AKITDA initiative uniting Kerala’s IT retailers under a single, professional brand, offering benefits, technology, and support to empower local businesses.',
                  ),
                  const SizedBox(height: 24),

                  sectionTitle('Follow Us'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.greenAccent),
                        iconSize: 30,
                        onPressed: () => _launchURL('https://wa.me/919447075216'),
                        tooltip: 'WhatsApp',
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.facebook, color: Colors.blueAccent),
                        iconSize: 30,
                        onPressed: () => _launchURL('https://facebook.com/asajaitsolutions'),
                        tooltip: 'Facebook',
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.instagram, color: Colors.purpleAccent),
                        iconSize: 30,
                        onPressed: () => _launchURL('https://instagram.com/asajaitsolutions'),
                        tooltip: 'Instagram',
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Divider(color: Colors.white24, thickness: 1),

                  const SizedBox(height: 24),
                  sectionTitle('Contact Us'),
                  const SizedBox(height: 12),
                  sectionBody(
                    '1st Floor Krishnakripa KSN Road,\nNear South Over Bridge,\nErnakulam, Kochi',
                  ),
                  TextButton.icon(
                    onPressed: () => _launchURL('https://maps.app.goo.gl/EYDanSJgtTzdNXoL8'),
                    icon: const Icon(Icons.location_on, color: orange),
                    label: const Text(
                      'View Location on Map',
                      style: TextStyle(
                        color: orange,
                        decoration: TextDecoration.underline,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  sectionBody('+91 94470 75216'),
                  const SizedBox(height: 12),
                  sectionTitle('Office Hours'),
                  const SizedBox(height: 8),
                  sectionBody('Monday – Saturday : 8am to 5pm\nSunday : Closed'),

                  const SizedBox(height: 32),
                  const Divider(color: Colors.white24, thickness: 1),

                  const SizedBox(height: 32),
                  sectionBody('“Empowering IT Retail – United by Brand, Driven by Trust.”'),
                  const SizedBox(height: 24),

                  sectionTitle('Marketing & Promotions'),
                  const SizedBox(height: 12),
                  sectionBody(
                    '• Centralized advertisements on TV, print, and social media\n'
                        '• Seasonal campaigns and festival promotions\n'
                        '• AKITDA-endorsed brand recognition\n'
                        '• Event participation and networking opportunities',
                  ),

                  const SizedBox(height: 24),
                  sectionTitle('Technology Support'),
                  const SizedBox(height: 12),
                  sectionBody(
                    '• Flexible tech solutions tailored to your store size and staff\n'
                        '• Integration with billing, inventory, and customer management tools\n'
                        '• Technical support and regular updates included\n'
                        '• Optional hardware packages available',
                  ),

                  const SizedBox(height: 24),
                  sectionTitle('Empowering Kerala’s IT Retail Sector'),
                  const SizedBox(height: 12),
                  sectionBody(
                    'IT Shoppe – An AKITDA Initiative to unify and modernize local IT dealers under one trusted, professional brand.',
                  ),

                  const SizedBox(height: 24),
                  sectionTitle('Join Us'),
                  const SizedBox(height: 12),
                  sectionBody(
                    'AKITDA’s IT Shoppe is Kerala’s first unified retail initiative aimed at elevating the IT retail experience. By bringing independent dealers under a common brand, we ensure quality, consistency, and trust for customers—while empowering our members with the tools to succeed in a digital-first world.',
                  ),

                  const SizedBox(height: 40),
                  Text(
                    '© 2025 IT Shopee. All rights reserved.',
                    style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Footer Navigation Bar
          Padding(
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
                  // _navIcon(Icons.shopping_cart, () {
                  //   // You might need to pass email/userId here if ProductPage requires them
                  //   Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductPage()));
                  // }),
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
}
