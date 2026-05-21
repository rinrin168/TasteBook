import 'package:flutter/material.dart';
import 'package:app/core/theme.dart';
import '../widgets/auth_card.dart';
import '../widgets/buttons.dart';

class AuthSuccessScreen extends StatelessWidget {
  const AuthSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TasteBookColors.tan,
      body: SafeArea(
        child: AuthCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 84,
                color: TasteBookColors.cocoa,
              ),
              const SizedBox(height: 12),
              Text(
                'Success',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: TasteBookColors.espresso,
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/home'),
                label: 'Go to Home',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
