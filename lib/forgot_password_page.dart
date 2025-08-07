import 'package:flutter/material.dart';

const darkBlue = Color(0xFF1E2B6D);
const cardBlue = Color(0xFF2C3E91);
const orange = Color(0xFFF65A06);

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isSending = false;

  void _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    // Simulate sending email
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isSending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset link sent to your email')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        backgroundColor: darkBlue,
        foregroundColor: orange,
        title: const Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          color: cardBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter your email address to receive a password reset link.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: orange),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: orange),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: orange.withOpacity(0.8)),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.redAccent),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.redAccent),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      final emailRegex = RegExp(
                          r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                      if (!emailRegex.hasMatch(value)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _sendResetLink,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSending
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                          : const Text(
                        'Send Reset Link',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
