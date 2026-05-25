import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/core/theme.dart';
import '../../../services/auth_service.dart';
import '../widgets/auth_card.dart';
import '../widgets/inputs.dart';
import '../widgets/buttons.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _errorText;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_isSubmitting) return;

    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorText = 'Please enter and confirm your new password.';
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _errorText = 'Passwords do not match.';
      });
      return;
    }

    if (newPassword.length < 6) {
      setState(() {
        _errorText = 'Password must be at least 6 characters long.';
      });
      return;
    }

    setState(() {
      _errorText = null;
      _isSubmitting = true;
    });

    try {
      await AuthService.instance.updateProfile(
        displayName: '',
        email: '',
        password: newPassword,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/auth/success');
    } on FirebaseAuthException catch (error) {
      setState(() {
        if (error.code == 'requires-recent-login') {
          _errorText =
              'Security timeout. Please log out and back in to change your password.';
        } else {
          _errorText = error.message ?? error.code;
        }
      });
    } catch (error) {
      setState(() {
        _errorText = error.toString();
      });
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
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AuthCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: TasteBookColors.espresso,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Reset Password',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: TasteBookColors.espresso,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AuthTextField(
                    controller: _newPasswordController,
                    hint: 'New password',
                    obscure: true,
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    controller: _confirmPasswordController,
                    hint: 'Confirm password',
                    obscure: true,
                  ),
                  if (_errorText != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      _errorText!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  PrimaryButton(
                    onPressed: _isSubmitting ? () {} : _resetPassword,
                    label: _isSubmitting ? 'Updating...' : 'Reset Password',
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
