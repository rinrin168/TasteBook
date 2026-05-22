import 'package:flutter/material.dart';
import 'package:app/core/theme.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TasteBookColors.tan,
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: TasteBookColors.tan,
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(
                child: Image.asset(
                  'assets/images/img1.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              Container(
                color: const Color(0xFFD8C8BB),
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
                child: Text(
                  'Welcome to your TasteBook! Discover tasty recipes, share your favorite dishes, and explore new meals anytime, anywhere.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: TasteBookColors.espresso,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                  ),
                ),
              ),
              Container(
                color: TasteBookColors.tan,
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pushReplacementNamed('/auth/login'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFD0BEB0),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.7),
                          width: 1,
                        ),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
