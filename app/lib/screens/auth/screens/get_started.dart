import 'package:flutter/material.dart';
import 'package:app/core/theme.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TasteBookColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              // Main Hero Logo
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: TasteBookColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: TasteBookColors.cocoa.withValues(alpha: 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 140,
                    width: 140,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // App Title with premium typography
              Text(
                'TasteBook',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 42,
                  color: TasteBookColors.cocoa,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 18),
              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Discover tasty recipes, share your favorite dishes, and explore new meals anytime, anywhere.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: TasteBookColors.espresso.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const Spacer(flex: 3),
              // CTA Button
              FilledButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/auth/login'),
                style: FilledButton.styleFrom(
                  backgroundColor: TasteBookColors.cocoa,
                  foregroundColor: TasteBookColors.white,
                  minimumSize: const Size.fromHeight(60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                  shadowColor: TasteBookColors.cocoa.withValues(alpha: 0.3),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
