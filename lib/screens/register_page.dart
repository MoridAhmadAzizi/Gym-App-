import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/my_button.dart';
import '../components/my_text_field.dart';
import '../services/auth_service.dart';
import 'otp_page.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  Future<void> _signUp() async {
    if (_loading) return;

    final email = _emailController.text.trim();
    final pass = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      _snack('همه فیلدها را پر کنید');
      return;
    }
    if (pass.length < 8) {
      _snack('پسورد باید حداقل ۸ کاراکتر باشد');
      return;
    }
    if (pass != confirm) {
      _snack('پسورد و تکرار پسورد یکسان نیست');
      return;
    }

    setState(() => _loading = true);
    try {
      await Get.find<AuthService>().signUpAndSendOtp(email: email, password: pass);
      if (!mounted) return;
      _snack('کد تایید به ایمیل شما ارسال شد', ok: true);
      Get.to(() => OtpPage(email: email));
    } catch (_) {
      if (!mounted) return;
      _snack('ثبت نام ناموفق! بعداً امتحان کنید.');
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
                  height: 290,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                Text(
                  'ثبت نام',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 20),
                MyTextField(controller: _emailController, hintText: 'ایمیل', obscureText: false),
                const SizedBox(height: 10),
                MyTextField(controller: _passwordController, hintText: 'پسورد', obscureText: true),
                const SizedBox(height: 10),
                MyTextField(controller: _confirmPasswordController, hintText: 'تکرار پسورد', obscureText: true),
                const SizedBox(height: 16),
                MyButton(text: _loading ? '...' : 'ثبت نام', onTap: _loading ? null : _signUp),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('حساب دارید؟'),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text('ورود', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w800)),
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
