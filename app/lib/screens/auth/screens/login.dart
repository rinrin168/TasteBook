import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:app/core/theme.dart';

import '../../../services/auth_service.dart';

import '../widgets/auth_card.dart';
import '../widgets/buttons.dart';
import '../widgets/inputs.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final email = _emailController.text.trim();

    final password = _passwordController.text;

    // VALIDATION

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password.')),
      );

      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email.')),
      );

      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // LOGIN

      await AuthService.instance.signIn(email: email, password: password);

      if (!mounted) return;

      // GO TO HOME

      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Something went wrong.';

      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for this email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Incorrect email or password.';
      } else if (e.code == 'email-not-verified') {
        errorMessage = 'Please verify your email before logging in.';
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
                            Navigator.of(context).pushReplacementNamed('/auth/get-started');
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
                        'Log In',

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
                    'Welcome Back!',

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
                    'Log in to continue discovering and sharing delicious recipes.',

                    textAlign: TextAlign.center,

                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: TasteBookColors.espresso.withValues(alpha: 0.85),

                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 24),

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

                  const SizedBox(height: 8),

                  // FORGOT PASSWORD
                  Align(
                    alignment: Alignment.centerRight,

                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/auth/forgot-password');
                      },

                      child: const Text('Forgot Password?'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // LOGIN BUTTON
                  PrimaryButton(
                    onPressed: _isSubmitting ? () {} : _submit,

                    label: _isSubmitting ? 'Logging In...' : 'Log In',
                  ),

                  const SizedBox(height: 14),

                  // SIGNUP REDIRECT
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/auth/signup');
                      },

                      child: const Text("Don't have an account? Sign Up"),
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
