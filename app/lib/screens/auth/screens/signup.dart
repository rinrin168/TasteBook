import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:app/core/theme.dart';

import '../../../services/auth_service.dart';

import '../widgets/auth_card.dart';
import '../widgets/buttons.dart';
import '../widgets/inputs.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_isSubmitting) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // VALIDATION
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields.')),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters long.')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await AuthService.instance.signUp(
        fullName: name,
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/auth/verify-signup');
    } on FirebaseAuthException catch (e) {
      String errorMessage = e.message ?? e.code;
      if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already in use by another account.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not formatted correctly.';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
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
                  // HEADER
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
                        'Sign Up',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: TasteBookColors.espresso,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const Spacer(),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // LOGO
                  Center(
                    child: Image.asset('assets/images/logo.png', height: 75),
                  ),
                  const SizedBox(height: 16),

                  // TITLE
                  Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: TasteBookColors.espresso,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // DESCRIPTION
                  Text(
                    'Sign up to start discovering and sharing delicious recipes.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: TasteBookColors.espresso.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // FULL NAME
                  AuthTextField(
                    controller: _nameController,
                    hint: 'Full Name',
                    keyboardType: TextInputType.name,
                  ),

                  const SizedBox(height: 12),

                  // EMAIL
                  AuthTextField(
                    controller: _emailController,
                    hint: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 12),

                  // PASSWORD
                  AuthTextField(
                    controller: _passwordController,
                    hint: 'Password',
                    obscure: true,
                  ),

                  const SizedBox(height: 6),

                  // PASSWORD REQUIREMENT INFO
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: TasteBookColors.espresso,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Password must be at least 6 characters long.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: TasteBookColors.espresso.withValues(alpha: 0.75),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // CONFIRM PASSWORD
                  AuthTextField(
                    controller: _confirmPasswordController,
                    hint: 'Confirm Password',
                    obscure: true,
                  ),

                  const SizedBox(height: 24),

                  // SIGNUP BUTTON
                  PrimaryButton(
                    onPressed: _isSubmitting ? () {} : _handleSignUp,
                    label: _isSubmitting ? 'Creating Account...' : 'Sign Up',
                  ),

                  const SizedBox(height: 14),

                  // LOGIN REDIRECT
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/auth/login');
                      },
                      child: const Text("Already have an account? Log In"),
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
