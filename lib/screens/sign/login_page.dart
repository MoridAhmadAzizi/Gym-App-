import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wahab/components/my_button.dart';
import 'package:wahab/components/my_text_field.dart';
import 'package:wahab/services/auth_services.dart';

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
      await context
          .read<AuthService>()
          .signInWithPassword(email: email, password: pass);
      if (!mounted) return;
      _snack('با موفقیت وارد شدید ', ok: true);
      // اگر روت/ریدایرکت با auth listener انجام می‌شود، همین کافیست.
    } catch (e) {
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
                  'assets/images/sign.jpg',
                  width: double.infinity,
                  height: 290,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                Text(
                  'خوش آمدید',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: _emailController,
                  hintText: 'ایمیل',
                  obscureText: false,
                ),
                const SizedBox(height: 12),
                MyTextField(
                  controller: _passwordController,
                  hintText: 'پسورد',
                  obscureText: true,
                ),
                const SizedBox(height: 18),
                MyButton(
                  onTap: _loading ? null : _signIn,
                  text: _loading ? '...' : 'ورود',
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('حساب ندارید؟ '),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        'ثبت نام',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
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
