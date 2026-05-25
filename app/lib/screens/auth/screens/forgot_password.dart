import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/core/theme.dart';
import '../widgets/auth_card.dart';
import '../widgets/inputs.dart';
import '../widgets/buttons.dart';
import '../../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handlePasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnackBar('Please enter your email address.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Calls backend service to trigger official Firebase transactional email
      await AuthService.instance.sendPasswordReset(email);

      if (!mounted) return;
      _showSnackBar('Password reset link sent! Check your inbox.');

      // Send them to the check success screen
      Navigator.of(context).pushReplacementNamed(
        '/auth/success',
        arguments: {
          'title': 'Reset Link Sent',
          'message': 'We have sent a secure password reset link to your email address. Please follow the instructions to reset your password.',
          'buttonLabel': 'Back to Log In',
          'onPressedRoute': '/auth/login',
          'icon': Icons.mark_email_read_outlined,
        },
      );
    } on FirebaseAuthException catch (error) {
      _showSnackBar(error.message ?? error.code);
    } catch (error) {
      _showSnackBar(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TasteBookColors.cream,
      body: SafeArea(
        child: Center(
          child: AuthCard(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () async {
                          final didPop = await Navigator.of(context).maybePop();
                          if (!didPop && context.mounted) {
                            Navigator.of(context).pushReplacementNamed('/auth/login');
                          }
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: TasteBookColors.espresso,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Forgot Password',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: TasteBookColors.espresso,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enter your registered email below, and we will send you a secure link to reset your account credentials.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: TasteBookColors.espresso.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 18),
                  AuthTextField(
                    controller: _emailController,
                    hint: 'Email address',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    onPressed: _isSubmitting ? () {} : _handlePasswordReset,
                    label: _isSubmitting
                        ? 'Sending Link...'
                        : 'Send Recovery Link',
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
