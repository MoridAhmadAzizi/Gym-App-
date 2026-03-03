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
  final ValueNotifier<bool> _loadingNotifier = ValueNotifier(false);

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

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  Future<void> _signIn() async {
    _loadingNotifier.value = true;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _loadingNotifier.value = false;
      snack('ایمیل یا پسورد خالی است');

      return;
    }

    if (!_isValidEmail(email)) {
      _loadingNotifier.value = false;

      snack('ایمیل معتبر نیست');
      return;
    }

    try {
      final response = await AuthService(
        Supabase.instance.client,
      ).signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        snack('موفقانه وارد شده اید', success: true);
        if (mounted) {
          context.navigatorPushAndRemoveUntil(const EventScreen());
        }
      }
    } on AuthApiException catch (e) {
      switch (e.code) {
        case 'invalid_credentials':
          snack('ایمیل یا پسورد اشتباه است');
          break;

        case 'email_not_confirmed':
          snack('ایمیل شما تایید نشده است');
          break;

        case 'user_not_found':
          snack('کاربری با این ایمیل یافت نشد');
          break;

        default:
          snack('خطا در ورود: ${e.message}');
      }
    } catch (e) {
      snack('خطای غیرمنتظره رخ داده است');
    } finally {
      _loadingNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () {
                    context.navigatorPop();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.arrow_back_ios_outlined),
                  ),
                ),
              ),

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
              ValueListenableBuilder(
                  valueListenable: _loadingNotifier,
                  builder: (context, isLoading, child) {
                    return MyButton(text: isLoading ? '...' : 'ورود', onTap: isLoading ? null : _signIn);
                  }),
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
    );
  }
}
