import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/my_button.dart';
import '../components/my_text_field.dart';
import '../services/auth_service.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool ok = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: ok ? Colors.green.shade600 : Colors.red.shade600,
      ),
    );
  }

  Future<void> _signIn() async {
    if (_loading) return;

    final email = _emailController.text.trim();
    final pass = _passwordController.text;

    if (email.isEmpty || pass.isEmpty) {
      _snack('ایمیل و پسورد را وارد کنید');
      return;
    }

    setState(() => _loading = true);
    try {
      await Get.find<AuthService>().signInWithPassword(email: email, password: pass);
      if (!mounted) return;
      _snack('با موفقیت وارد شدید ', ok: true);
      Get.offAll(() => const Home());
    } catch (_) {
      if (!mounted) return;
      _snack('ورود ناموفق!');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/sign.png',
                  width: double.infinity,
                  height: 320,
                  fit: BoxFit.cover,
                ),
                Text(
                  'خوش آمدید',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 20),
                MyTextField(controller: _emailController, hintText: 'ایمیل', obscureText: false),
                const SizedBox(height: 10),
                MyTextField(controller: _passwordController, hintText: 'پسورد', obscureText: true),
                const SizedBox(height: 16),
                MyButton(text: _loading ? '...' : 'ورود', onTap: _loading ? null : _signIn),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('حساب ندارید؟'),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text('ثبت نام', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
