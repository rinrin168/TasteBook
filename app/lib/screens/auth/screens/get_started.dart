import 'package:flutter/material.dart';
import 'package:app/core/theme.dart';
import '../widgets/auth_card.dart';
import '../widgets/buttons.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TasteBookColors.tan,
      body: SafeArea(
        child: Center(
          child: AuthCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome to TasteBook',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: TasteBookColors.espresso,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'A clean recipe app for quick browsing, saving, and signing in on your phone.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TasteBookColors.espresso.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                PrimaryButton(
                  onPressed: () =>
                      Navigator.of(context).pushReplacementNamed('/auth/login'),
                  label: 'Continue to Log In',
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).pushReplacementNamed('/auth/signup'),
                  style: TextButton.styleFrom(
                    foregroundColor: TasteBookColors.cocoa,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Create a new account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
