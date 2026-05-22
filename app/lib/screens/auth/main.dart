import 'package:flutter/material.dart';
import 'package:app/core/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'widgets/auth_card.dart';
import 'widgets/buttons.dart';

class AuthGateway extends StatelessWidget {
  const AuthGateway({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder listens directly to the Firebase native authentication state stream
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If snapshot has user data, bypass this landing hub entirely
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user != null) {
            // Use a post-frame callback to trigger navigation outside of building contexts safely
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/home', (route) => false);
            });
            return const Scaffold(
              backgroundColor: TasteBookColors.tan,
              body: Center(
                child: CircularProgressIndicator(color: TasteBookColors.cocoa),
              ),
            );
          }
        }

        // Default landing interface displayed when user is unauthenticated
        return Scaffold(
          backgroundColor: TasteBookColors.tan,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                _PillChip(
                                  label: 'TasteBook',
                                  background: TasteBookColors.tan.withValues(
                                    alpha: 0.14,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () =>
                                      Navigator.of(context).maybePop(),
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 18,
                                    color: TasteBookColors.espresso,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Welcome Back!',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: TasteBookColors.espresso,
                                    fontWeight: FontWeight.w800,
                                    height: 1.05,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'A clean, phone-first entry point for browsing recipes and signing in quickly.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: TasteBookColors.espresso.withValues(
                                      alpha: 0.8,
                                    ),
                                    height: 1.4,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      AuthCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Choose a route',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: TasteBookColors.espresso,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Get started, log in, or create a new account.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: TasteBookColors.espresso.withValues(
                                      alpha: 0.78,
                                    ),
                                    height: 1.35,
                                  ),
                            ),
                            const SizedBox(height: 18),
                            PrimaryButton(
                              onPressed: () => Navigator.of(
                                context,
                              ).pushNamed('/auth/get-started'),
                              label: 'Get Started',
                            ),
                            const SizedBox(height: 12),
                            PrimaryButton(
                              onPressed: () => Navigator.of(
                                context,
                              ).pushNamed('/auth/login'),
                              label: 'Log In',
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => Navigator.of(
                                context,
                              ).pushNamed('/auth/forgot-password'),
                              style: TextButton.styleFrom(
                                foregroundColor: TasteBookColors.cocoa,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                              child: const Text('Forgot Password?'),
                            ),
                            const SizedBox(height: 4),
                            PrimaryButton(
                              onPressed: () => Navigator.of(
                                context,
                              ).pushNamed('/auth/signup'),
                              label: 'Sign Up',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PillChip extends StatelessWidget {
  const _PillChip({required this.label, this.background});

  final String label;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background ?? TasteBookColors.sand.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: TasteBookColors.sand.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: TasteBookColors.espresso,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
