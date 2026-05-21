import 'package:flutter/material.dart';
import 'package:app/core/theme.dart';
import '../widgets/auth_card.dart';
import '../widgets/inputs.dart';
import '../widgets/buttons.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

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
                    'Create Account',
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
                "Let's Start!",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: TasteBookColors.espresso,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 12),
              const AuthTextField(hint: 'Full name'),
              const SizedBox(height: 12),
              const AuthTextField(
                hint: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              const AuthTextField(hint: 'Password', obscure: true),
              const SizedBox(height: 12),
              const AuthTextField(hint: 'Confirm Password', obscure: true),
              const SizedBox(height: 16),
              PrimaryButton(
                onPressed: () => Navigator.of(
                  context,
                ).pushReplacementNamed('/auth/verify-signup'),
                label: 'Sign Up',
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/auth/login'),
                  style: TextButton.styleFrom(
                    foregroundColor: TasteBookColors.cocoa,
                  ),
                  child: const Text('Already have an account? Log in'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
