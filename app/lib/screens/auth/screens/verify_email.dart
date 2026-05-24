import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app/core/theme.dart';
import '../widgets/auth_card.dart';
import '../widgets/buttons.dart';
import '../../../services/auth_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isChecking = false;
  bool _isResending = false;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() {
      _cooldownSeconds = 30;
    });
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          _cooldownSeconds--;
        });
      }
    });
  }

  Future<void> _checkVerification() async {
    if (_isChecking) return;

    setState(() {
      _isChecking = true;
    });

    try {
      final user = AuthService.instance.currentUser;
      if (user != null) {
        await user.reload();
        if (AuthService.instance.currentUser?.emailVerified ?? false) {
          // Sign out so they must log in manually per request
          await AuthService.instance.signOut();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email verified successfully!')),
          );
          Navigator.of(context).pushReplacementNamed(
            '/auth/success',
            arguments: {
              'title': 'Email Verified',
              'message': 'Your email has been verified successfully. You can now log in to your account.',
              'buttonLabel': 'Go to Log In',
              'onPressedRoute': '/auth/login',
              'icon': Icons.check_circle_outline,
            },
          );
          return;
        }
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification link not clicked yet. Please check your inbox.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _resendVerification() async {
    if (_isResending || _cooldownSeconds > 0) return;

    setState(() {
      _isResending = true;
    });

    try {
      await AuthService.instance.sendEmailVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email resent!')),
      );
      _startCooldown();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  Future<void> _cancelAndSignOut() async {
    await AuthService.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/auth/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final email = user?.email ?? 'your email';

    return Scaffold(
      backgroundColor: TasteBookColors.tan,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AuthCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon header
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: TasteBookColors.tan.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mark_email_unread_outlined,
                        size: 64,
                        color: TasteBookColors.cocoa,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    'Verify your email',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: TasteBookColors.espresso,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    'We\'ve sent a verification link to:',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: TasteBookColors.espresso.withValues(alpha: 0.75),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: TasteBookColors.cocoa,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Please click the link in that email to verify your identity and finish setting up your account.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: TasteBookColors.espresso.withValues(alpha: 0.85),
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 28),

                  // Check Verification Button
                  PrimaryButton(
                    onPressed: _isChecking ? () {} : _checkVerification,
                    label: _isChecking ? 'Checking status...' : 'I\'ve Verified My Email',
                  ),
                  const SizedBox(height: 16),

                  // Resend Code Button
                  Center(
                    child: TextButton(
                      onPressed: _cooldownSeconds > 0 || _isResending
                          ? null
                          : _resendVerification,
                      child: Text(
                        _cooldownSeconds > 0
                            ? 'Resend email in ${_cooldownSeconds}s'
                            : 'Resend Verification Email',
                        style: TextStyle(
                          color: _cooldownSeconds > 0
                              ? Colors.grey
                              : TasteBookColors.cocoa,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  // Cancel / Sign out Button
                  Center(
                    child: TextButton(
                      onPressed: _cancelAndSignOut,
                      child: const Text(
                        'Cancel & Go Back',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
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
