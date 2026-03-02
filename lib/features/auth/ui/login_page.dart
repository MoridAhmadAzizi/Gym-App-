import 'package:events/core/extension/navigator_extension.dart';
import 'package:events/core/widgets/my_button.dart';
import 'package:events/core/widgets/my_text_field.dart';
import 'package:events/features/auth/services/auth_service.dart';
import 'package:events/features/events/ui/event_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void snack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green.shade600 : Colors.red.shade600,
      ),
    );
  }

  Future<void> _signIn() async {
    final response = await AuthService(Supabase.instance.client).signInWithPassword(email: _emailController.text, password: _passwordController.text);
    if (response.user != null) {
      snack('موفقانه وارد شده اید', success: true);
      if (mounted) {
        context.navigatorPushAndRemoveUntil(const EventScreen());
      }
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
                // const Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Text('حساب ندارید؟'),
                //     SizedBox(width: 4),
                //     // InkWell(
                //     //   onTap: () {
                //     //     final supabase = Supabase.instance.client.auth.currentUser;
                //     //   },
                //     //   child: Text('ثبت نام', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w800)),
                //     // ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
