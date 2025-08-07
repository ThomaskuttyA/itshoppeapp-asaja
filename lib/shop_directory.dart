import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'homepage.dart';
import 'constants.dart';
import 'aboutus.dart';
import 'dashboard.dart';
import 'main.dart';
import 'messages.dart';
import 'notification.dart';

class ShopDirectoryPage extends StatefulWidget {
  const ShopDirectoryPage({super.key});
  @override
  State<ShopDirectoryPage> createState() => _ShopDirectoryPageState();
}

class _ShopDirectoryPageState extends State<ShopDirectoryPage> {
  List<dynamic> _allShops = [];
  List<dynamic> _displayedShops = [];
  bool _isLoading = true;
  String? _error;

  final int _pageSize = 10;
  int _currentPage = 0;
  String _searchTerm = '';
  String? _selectedDistrict = 'All Districts';
  final TextEditingController _searchController = TextEditingController();
  final List<String> _districts = [
    'All Districts','Alappuzha','Ernakulam','Idukki','Kannur','Kasaragod',
    'Kollam','Kottayam','Kozhikode','Malappuram','Palakkad','Pathanamthitta',
    'Thiruvananthapuram','Thrissur','Wayanad'
  ];

  @override
  void initState() {
    super.initState();
    fetchShops();
  }

  Future<void> fetchShops() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/get_shops.php'));
      if (res.statusCode == 200) {
        _allShops = jsonDecode(res.body);
        _applySearchAndPagination();
        setState(() => _isLoading = false);
      } else {
        setState(() {
          _error = 'Server error: ${res.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load shops';
        _isLoading = false;
      });
    }
  }

  void _applySearchAndPagination() {
    var filtered = _allShops.where((s) {
      final n = (s['name'] ?? '').toString().toLowerCase();
      final c = (s['city'] ?? '').toString().toLowerCase();
      final d = (s['district'] ?? '').toString();
      final dm = _selectedDistrict == 'All Districts' ||
          d.toLowerCase() == _selectedDistrict!.toLowerCase();
      final sm = n.contains(_searchTerm) || c.contains(_searchTerm);
      return dm && sm;
    }).toList();

    final start = _currentPage * _pageSize;
    if (start >= filtered.length) _currentPage = 0;
    final end = (_currentPage + 1) * _pageSize;
    _displayedShops = filtered.sublist(start, end.clamp(0, filtered.length));

    setState(() {});
  }

  void _onSearchChanged() {
    _searchTerm = _searchController.text.trim().toLowerCase();
    _currentPage = 0;
    _applySearchAndPagination();
  }

  void _onDistrictChanged(String? v) {
    setState(() {
      _selectedDistrict = v;
      _currentPage = 0;
      _applySearchAndPagination();
    });
  }

  void _goNextPage() {
    _currentPage++;
    _applySearchAndPagination();
  }

  void _goPreviousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      _applySearchAndPagination();
    }
  }

  Future<void> logShopContact({
    required int shopId,
    required String contactType,
    required String contactValue,
  }) async {
    final url = Uri.parse('$baseUrl/log_contact.php');
    try {
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'shop_id': shopId,
          'contact_type': contactType,
          'contact_value': contactValue,
        }),
      );
    } catch (e) {
      debugPrint('Failed to log contact: $e');
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('❌ Cannot launch URL: $url');
      _showSnackBar('Could not open: $url');
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _navIcon(IconData icon, VoidCallback onTap) {
    return IconButton(icon: Icon(icon, color: Colors.white), onPressed: onTap);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2B6D),
      appBar: AppBar(
        title: const Text('Shop Directory'),
        backgroundColor: const Color(0xFF1E2B6D),
        foregroundColor: const Color(0xFFF65A06),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  value: _selectedDistrict,
                  items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: _onDistrictChanged,
                  dropdownColor: const Color(0xFF2C3E91),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white24,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 7,
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => _onSearchChanged(),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search shops or city...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
            ]),
          ),
          Expanded(child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFF65A06)))
              : (_error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.white)))
              : _displayedShops.isEmpty
              ? const Center(child: Text('No shops found.', style: TextStyle(color: Colors.white70)))
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _displayedShops.length,
            itemBuilder: (context, index) {
              final shop = _displayedShops[index];
              final shopId = int.tryParse(shop['id'].toString()) ?? 0;
              return Card(
                color: const Color(0xFF2C3E91),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFF65A06).withOpacity(0.15),
                    child: const Icon(Icons.store, color: Color(0xFFF65A06)),
                  ),
                  title: Text(
                    shop['name'] ?? '',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(shop['address'] ?? '', style: const TextStyle(color: Colors.white70)),
                    Text('District: ${shop['district'] ?? '-'}', style: const TextStyle(color: Colors.white70)),
                    Text('City: ${shop['city'] ?? '-'}', style: const TextStyle(color: Colors.white70)),
                    Text('Phone: ${shop['phone'] ?? '-'}', style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Row(children: [
                      // CALL
                      IconButton(
                        icon: const Icon(Icons.phone, color: Colors.greenAccent),
                        onPressed: () {
                          final raw = shop['phone']?.toString() ?? '';
                          final formatted = raw.replaceAll(RegExp(r'[^0-9]'), '');
                          if (formatted.isNotEmpty) {
                            logShopContact(shopId: shopId, contactType: 'call', contactValue: formatted);
                            _launchUrl('tel:$formatted');
                          } else {
                            _showSnackBar('Phone not available');
                          }
                        },
                      ),
                      // WHATSAPP
                      IconButton(
                        icon: const Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
                        onPressed: () {
                          final raw = shop['whatsapp'] ?? shop['phone'];
                          final formatted = raw?.toString().replaceAll(RegExp(r'[^0-9]'), '');
                          if (formatted != null && formatted.isNotEmpty) {
                            logShopContact(shopId: shopId, contactType: 'whatsapp', contactValue: formatted);
                            final encodedMsg = Uri.encodeComponent("Hello from IT Shoppe!");
                            _launchUrl('https://wa.me/$formatted?text=$encodedMsg');
                          } else {
                            _showSnackBar('WhatsApp not available');
                          }
                        },
                      ),
                      // EMAIL
                      IconButton(
                        icon: const Icon(Icons.email, color: Colors.orangeAccent),
                        onPressed: () {
                          final email = shop['shop_email'] ?? shop['member_email'];
                          if (email != null && email.isNotEmpty) {
                            logShopContact(shopId: shopId, contactType: 'email', contactValue: email);
                            final subject = Uri.encodeComponent("Inquiry from IT Shoppe");
                            final body = Uri.encodeComponent("Hello,\n\nI found your shop in IT Shoppe.");
                            _launchUrl('mailto:$email?subject=$subject&body=$body');
                          } else {
                            _showSnackBar('Email not available');
                          }
                        },
                      ),
                    ]),
                  ]),
                ),
              );
            },
          ))),
          if (!_isLoading && _error == null && _allShops.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ElevatedButton(
                  onPressed: _currentPage > 0 ? _goPreviousPage : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF65A06),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Previous'),
                ),
                const SizedBox(width: 12),
                Text('Page ${_currentPage + 1}', style: const TextStyle(color: Colors.white70)),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: ((_currentPage + 1) * _pageSize < _allShops.where((s) {
                    final n = (s['name'] ?? '').toString().toLowerCase();
                    final c = (s['city'] ?? '').toString().toLowerCase();
                    final d = (s['district'] ?? '').toString().toLowerCase();
                    final dm = _selectedDistrict == 'All Districts' || d == _selectedDistrict!.toLowerCase();
                    final sm = n.contains(_searchTerm) || c.contains(_searchTerm);
                    return dm && sm;
                  }).length)
                      ? _goNextPage
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF65A06),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Next'),
                ),
              ]),
            )
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Container(
          height: 60,
          decoration: BoxDecoration(color: Colors.deepOrange, borderRadius: BorderRadius.circular(16), boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(2, 4))
          ]),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            // _navIcon(Icons.home, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomePage()))),
            _navIcon(Icons.notifications, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NotificationPage()))),
            _navIcon(Icons.message, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagesPage()))),
            _navIcon(Icons.logout, () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false))
          ]),
        ),
      ),
    );
  }
}
