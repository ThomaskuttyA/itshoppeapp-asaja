import 'package:flutter/material.dart';
import 'homepage.dart';
import 'register.dart';
import 'constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_session.dart';
import 'forgot_password_page.dart';
import 'dashboard.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IT SHOPEE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _showSuccess = false;
  bool _obscurePassword = true;

  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnim = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _opacityAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('$baseUrl/login.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        UserSession().userId = data['user']['id'];
        UserSession().username = data['user']['username'];
        await UserSession().saveToPrefs();

        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _showSuccess = true;
        });

        await _animController.forward();
        await Future.delayed(const Duration(seconds: 1));
        await _animController.reverse();

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(
              email: data['user']['email'],
              userId: data['user']['id'],
            ),
          ),
        );
      } else {
        setState(() => _isLoading = false);
        _showAlert('Login Failed', 'Invalid credentials');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showAlert('Error', 'Failed to connect to server.');
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2B6D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/wrong.json',
              height: 120,
              repeat: false,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.orangeAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A3A80),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                color: const Color(0xFF1E2B6D),
                elevation: 16,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/itlogo.png', height: 100),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _usernameController,
                          style: const TextStyle(color: Color(0xFFF65A06)),
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Enter username' : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Color(0xFFF65A06)),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (v) => v == null || v.length < 6 ? 'Password must be 6+ chars' : null,
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF65A06),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                              'Login',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? ",
                                style: TextStyle(color: Colors.black54)),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                                );
                              },
                              child: const Text(
                                "Register here",
                                style: TextStyle(
                                  color: Color(0xFFF65A06),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                            );
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Colors.grey,
                              decoration: TextDecoration.underline,
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
          if (_showSuccess)
            Positioned.fill(
              child: FadeTransition(
                opacity: _opacityAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    color: Colors.black54,
                    alignment: Alignment.center,
                    child: Lottie.asset(
                      'assets/animations/ok.json',
                      height: 180,
                      repeat: false,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
