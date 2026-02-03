import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:wahab/services/auth_services.dart';
import 'package:wahab/services/profile_repo.dart';

class OtpPage extends StatefulWidget {
  final String email;
  const OtpPage({super.key, required this.email});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  DateTime? _lastResendAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _snack(String msg, {bool ok = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: ok ? Colors.green.shade600 : Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool _canResendNow() {
    if (_lastResendAt == null) return true;
    return DateTime.now().difference(_lastResendAt!).inSeconds >= 30;
  }

  Future<void> _resend() async {
    if (!_canResendNow()) {
      _snack('لطفاً ۳۰ ثانیه صبر کنید و دوباره تلاش کنید.');
      return;
    }

    setState(() {
      _loading = true;
      _lastResendAt = DateTime.now();
    });

    try {
      await context.read<AuthService>().resendSignupOtp(email: widget.email);
      if (!mounted) return;
      _snack('کد جدید ارسال شد  (فقط آخرین کد معتبر است)', ok: true);
      _clearFields();
      _focusNodes[0].requestFocus();
    } catch (e) {
      if (!mounted) return;
      _snack('ارسال مجدد ناموفق!');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _getCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  void _clearFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
  }

  void _handleInput(String value, int index) {
    if (value.isNotEmpty && !RegExp(r'^\d$').hasMatch(value)) {
      _controllers[index].clear();
      return;
    }

    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    if (index == 5 && value.isNotEmpty) {
      _focusNodes[index].unfocus();
    }
  }

  void _handleBackspace(RawKeyEvent event, int index) {
    if (event.logicalKey == LogicalKeyboardKey.backspace &&
        event is RawKeyDownEvent) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
        _controllers[index - 1].clear();
      }
      else if (_controllers[index].text.isNotEmpty) {
        _controllers[index].clear();
      }
    }
  }

  Future<void> _verify() async {
    if (_loading) return;

    final code = _getCode();

    if (code.length != 6) {
      _snack('لطفاً تمام ۶ رقم کد را وارد کنید');
      for (int i = 0; i < _controllers.length; i++) {
        if (_controllers[i].text.isEmpty) {
          _focusNodes[i].requestFocus();
          break;
        }
      }
      return;
    }

    setState(() => _loading = true);
    try {
      await context.read<AuthService>().verifySignupOtp(email: widget.email, token: code);

      // اگر پروفایل نبود بساز
      await context.read<ProfileRepo>().ensureProfile();

      if (!mounted) return;
      _snack('تایید شد. ', ok: true);

      context.go('/');
    } catch (e) {
      if (!mounted) return;
      _snack('کد اشتباه است یا منقضی/باطل شده.');
      _clearFields();
      _focusNodes[0].requestFocus();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _handlePaste(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length >= 6) {
      for (int i = 0; i < 6; i++) {
        _controllers[i].text = digitsOnly[i];
      }
      _focusNodes[5].unfocus();
    } else if (digitsOnly.isNotEmpty) {
      for (int i = 0; i < digitsOnly.length && i < 6; i++) {
        _controllers[i].text = digitsOnly[i];
      }
      if (digitsOnly.length < 6) {
        _focusNodes[digitsOnly.length].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canResend = _canResendNow();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تایید ایمیل'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/images/otp.jpg',
                  width: double.infinity,
                  height: 290,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),

                Text(
                  'کد تأیید را وارد کنید',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'کد ۶ رقمی به ایمیل زیر ارسال شد:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      widget.email,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                // ورودی‌های OTP
                Row(
                  textDirection: TextDirection.ltr,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return RawKeyboardListener(
                      focusNode: FocusNode(),
                      onKey: (RawKeyEvent event) {
                        _handleBackspace(event, index);
                      },
                      child:
                      SizedBox(
                        width: 52,
                        height: 60,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(9),
                              borderSide: BorderSide(
                                color: _controllers[index].text.isNotEmpty
                                  ? colorScheme.primary
                                  : Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(9),
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: _controllers[index].text.isNotEmpty
                                ? colorScheme.primary.withOpacity(0.05)
                                : Colors.white,
                            contentPadding: const EdgeInsets.all(8),
                          ),
                          onChanged: (value) {
                            _handleInput(value, index);
                          },
                          onTap: () {
                            if (_controllers[index].text.isNotEmpty) {
                              _controllers[index].selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: _controllers[index].text.length,
                              );
                            }
                          },
                        ),
                      ),
                    );
                  }),
                ),

                // تایمر برای ارسال مجدد
                const SizedBox(height: 30),

                FilledButton(
                  onPressed: _loading ? null : _verify,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),

                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.verified, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              'تایید کد',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: (_loading || !canResend) ? null : _resend,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  icon: Icon(
                    Icons.refresh,
                    color: canResend ? colorScheme.primary : Colors.grey.shade400,
                  ),
                  label: Text(
                    canResend ? 'ارسال مجدد کد' : 'صبر کنید...',
                    style: TextStyle(
                      color: canResend ? colorScheme.primary : Colors.grey.shade400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 20,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}