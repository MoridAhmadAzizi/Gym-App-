import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:wahab/services/auth_services.dart';
import 'package:wahab/screens/sign/my_button.dart';
import 'package:wahab/screens/sign/my_text_field.dart';
import 'package:wahab/screens/sign/squre_tile.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void signUserUp() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent user from dismissing by tapping outside
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      if (passwordController.text == confirmPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: usernameController.text.trim(),
          password: passwordController.text.trim(),
        );
      } else {
        showErrorMassage("passwords don't matach!");
      }

      // Close loading dialog
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // Close loading dialog first
      Navigator.pop(context);

      // Show error message
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
      // Close loading dialog
      Navigator.pop(context);

      // Show generic error
      showErrorMassage('ops:something happended:$e');
    }
  }

  void showErrorMassage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: AlertDialog(
            backgroundColor: Colors.deepPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Text(
              message,
              style: TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
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
                SizedBox(height: 50),
                Icon(Icons.lock, size: 100),
                SizedBox(height: 50),
                Text(
                  'Let\'s Create an account for you!',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
                SizedBox(height: 25),
                MyTextField(
                  obsucreText: false,
                  hintText: 'Enter your username',
                  controller: usernameController,
                ),
                SizedBox(height: 10),
                MyTextField(
                  obsucreText: true,
                  hintText: 'Enter your password',
                  controller: passwordController,
                ),
                SizedBox(height: 10),
                MyTextField(
                  obsucreText: true,
                  hintText: 'Confirm your password',
                  controller: confirmPasswordController,
                ),
                SizedBox(height: 10),
                SizedBox(height: 25),
                MyButton(
                  onTap: signUserUp,
                  button: 'Sign up',
                ),
                SizedBox(height: 50),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(thickness: 0.5, color: Colors.grey[400]),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
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
                      onTap: () {}, // Apple ID - فعلاً خالی
                      text: 'Sign Up with your Apple ID',
                    ),
                    const SizedBox(height: 10),
                    SqureTile(
                      icon: Logo(Logos.google, size: 28),
                      onTap: () => AuthService().signInWithGoogle(),// اصلاح شد
                      text: 'Sign Up with your Google Account',
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Login now',
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