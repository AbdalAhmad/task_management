import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _verificationSent = false;
  bool _emailVerified = false;
  bool _canResend = true;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  /// 🔐 SIGN UP
  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await credential.user!.sendEmailVerification();

      setState(() => _verificationSent = true);

      _showMessage(
        'Verification email sent. Please check inbox or spam.',
        Colors.blue,
      );
    } on FirebaseAuthException catch (e) {
      String msg = 'Signup failed';

      if (e.code == 'email-already-in-use') {
        msg = 'User already exists. Please login.';
      } else if (e.code == 'weak-password') {
        msg = 'Password must be at least 6 characters.';
      }

      _showMessage(msg, Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// ✅ VERIFY EMAIL BUTTON (NEAR EMAIL FIELD)
  Future<void> _checkVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await user.reload();

    if (user.emailVerified) {
      setState(() => _emailVerified = true);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showMessage(
        'Email verified successfully. Please login.',
        Colors.green,
      );

      await FirebaseAuth.instance.signOut();

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    } else {
      _showMessage(
        'Email not verified yet. Please check your inbox.',
        Colors.orange,
      );
    }
  }

  /// 🔄 RESEND EMAIL
  Future<void> _resendEmail() async {
    if (!_canResend) return;

    setState(() => _canResend = false);

    await FirebaseAuth.instance.currentUser?.sendEmailVerification();

    _showMessage('Verification email resent', Colors.blue);

    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) setState(() => _canResend = true);
    });
  }

  void _showMessage(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// EMAIL + VERIFY BUTTON
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _emailController,
                      enabled: !_verificationSent,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) =>
                          v != null && v.contains('@')
                              ? null
                              : 'Invalid email',
                    ),
                  ),
                  const SizedBox(width: 8),

                  if (_verificationSent && !_emailVerified)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: ElevatedButton(
                        onPressed: _checkVerification,
                        child: const Text(
                          'Verify',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),

              if (_verificationSent && !_emailVerified)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: _canResend ? _resendEmail : null,
                    child: Text(
                      _canResend
                          ? 'Resend verification email'
                          : 'Resend in 30s',
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              /// PASSWORD
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) =>
                    v != null && v.length >= 6
                        ? null
                        : 'Min 6 characters',
              ),
              const SizedBox(height: 16),

              /// CONFIRM PASSWORD
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () => setState(
                        () => _obscureConfirmPassword =
                            !_obscureConfirmPassword),
                  ),
                ),
                validator: (v) =>
                    v == _passwordController.text
                        ? null
                        : 'Passwords do not match',
              ),
              const SizedBox(height: 24),

              /// SIGN UP BUTTON
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signup,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Sign Up'),
                ),
              ),

              if (_emailVerified) ...[
                const SizedBox(height: 24),
                const Icon(Icons.verified, color: Colors.green, size: 60),
                const Text(
                  'Email verified successfully!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
