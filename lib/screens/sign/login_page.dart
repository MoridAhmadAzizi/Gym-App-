import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:wahab/services/auth_services.dart';
import 'package:wahab/screens/sign/my_button.dart';
import 'package:wahab/screens/sign/my_text_field.dart';
import 'package:wahab/screens/sign/squre_tile.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context);
      }

      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No User found with this Email';
          break;
        case 'wrong-password':
          errorMessage = 'Password is incorrect';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email';
          break;
        case 'user-disabled':
          errorMessage = 'This Account has been disabled';
          break;
        case 'too-many-requests':
          errorMessage = 'Many attempts , try later';
          break;
        default:
          errorMessage = 'error: ${e.message}';
      }

      showErrorMassage(errorMessage);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
      }
      // Show generic error
      showErrorMassage('ops:something happended:$e');
    }
  }

  void showErrorMassage(String message) {
     ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const Icon(Icons.lock, size: 100),
                const SizedBox(height: 50),
                Text(
                  'Welcome Back you have been missed',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  obsucreText: false,
                  hintText: 'Enter your username',
                  controller: usernameController,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  obsucreText: true,
                  hintText: 'Enter your password',
                  controller: passwordController,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot the password?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                MyButton(
                  onTap: signUserIn,
                  button: 'Sign In',
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(thickness: 0.5, color: Colors.grey[400]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or Continue with',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(thickness: 0.5, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SqureTile(
                      icon: Logo(
                        Logos.apple,
                        size: 28,
                      ),
                      onTap: () {},
                      text: 'Sign In With your Apple ID',
                    ),
                    const SizedBox(height: 10),
                    SqureTile(
                      icon: Logo(Logos.google, size: 28),
                      onTap: () => AuthService().signInWithGoogle(),
                      text: 'Sign In With your Google Account',
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member yet?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Register Now',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
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
