import 'package:flutter/material.dart';
import 'constants.dart'; // your baseUrl here
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullnameController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _placeController = TextEditingController();

  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final url = Uri.parse('$baseUrl/register.php');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullname': _fullnameController.text.trim(),
          'dob': _dobController.text.trim(),
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'username': _usernameController.text.trim(),
          'password': _passwordController.text.trim(),
          'place': _placeController.text.trim(),
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _showAlert('Success', 'User registered successfully', onOk: () {
            Navigator.pop(context); // Go back to login or previous page
          });
        } else {
          _showAlert('Registration Failed', data['message'] ?? 'Unknown error');
        }
      } else {
        _showAlert('Error', 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showAlert('Error', 'Failed to connect to server.');
    }
  }

  void _showAlert(String title, String message, {VoidCallback? onOk}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2B6D),
        title: Text(title, style: const TextStyle(color: Color(0xFFF65A06))),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onOk != null) onOk();
            },
            child: const Text('OK', style: TextStyle(color: Color(0xFFF65A06))),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2B6D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2B6D),
        elevation: 0,
        title: const Text('Register', style: TextStyle(color: Color(0xFFF65A06))),
        iconTheme: const IconThemeData(color: Color(0xFFF65A06)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Card(
            color: const Color(0xFF2A3A80),
            elevation: 14,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Title
                    const Text(
                      'Create your account',
                      style: TextStyle(
                        color: Color(0xFFF65A06),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Two columns - Full Name & DOB
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                              _fullnameController, 'Full Name', Icons.person),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: _dobField()),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Two columns - Phone & Email
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            _phoneController,
                            'Phone Number',
                            Icons.phone,
                            keyboardType: TextInputType.phone,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Enter phone number';
                              }
                              if (!RegExp(r'^\+?\d{7,15}$').hasMatch(v)) {
                                return 'Enter valid phone number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            _emailController,
                            'Email',
                            Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Enter email';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                                return 'Enter valid email';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Two columns - Username & Password
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            _usernameController,
                            'Username',
                            Icons.person_outline,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Enter username';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.lock),
                              labelStyle: TextStyle(color: Colors.white70),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.white24, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Color(0xFFF65A06), width: 2),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Place full width
                    _buildTextField(_placeController, 'Place', Icons.location_city,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter place';
                          return null;
                        }),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF65A06),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                            : const Text(
                          'Register',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Date of birth with picker
  Widget _dobField() {
    return TextFormField(
      controller: _dobController,
      readOnly: true,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        labelText: 'Date of Birth',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_today),
        labelStyle: TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFF65A06), width: 2),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Enter date of birth';
        return null;
      },
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            // Use your theme colors for the date picker dialog
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFFF65A06), // header background
                  onPrimary: Colors.white, // header text
                  onSurface: Colors.black, // body text
                ),
                dialogBackgroundColor: Colors.white,
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null) {
          _dobController.text = pickedDate.toIso8601String().split('T').first;
        }
      },
    );
  }

  // Helper to build text fields with your color scheme
  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24, width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFF65A06), width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
