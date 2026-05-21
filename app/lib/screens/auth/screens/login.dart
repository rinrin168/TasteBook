import 'package:flutter/material.dart';
import 'package:app/core/theme.dart';
import '../widgets/auth_card.dart';
import '../widgets/inputs.dart';
import '../widgets/buttons.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TasteBookColors.tan,
      body: SafeArea(
        child: AuthCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    'Log In',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: TasteBookColors.espresso,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 8),
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
              Text(
                'Discover, save, and share delicious recipes anytime. Our app makes browsing simple and signing in quick.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: TasteBookColors.espresso.withValues(alpha: 0.85),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              const AuthTextField(
                hint: 'Username or email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              const AuthTextField(hint: 'Password', obscure: true),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/auth/forgot-password'),
                  style: TextButton.styleFrom(
                    foregroundColor: TasteBookColors.cocoa,
                  ),
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/home'),
                label: 'Log In',
              ),
              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/auth/signup'),
                  style: TextButton.styleFrom(
                    foregroundColor: TasteBookColors.cocoa,
                  ),
                  child: const Text("Don't have an account? Sign Up"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
