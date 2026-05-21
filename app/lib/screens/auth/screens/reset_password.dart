import 'package:flutter/material.dart';
import 'package:app/core/theme.dart';
import '../widgets/auth_card.dart';
import '../widgets/inputs.dart';
import '../widgets/buttons.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TasteBookColors.tan,
      body: SafeArea(
        child: AuthCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Reset Password',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: TasteBookColors.espresso,
                ),
              ),
              const SizedBox(height: 12),
              const AuthTextField(hint: 'New password', obscure: true),
              const SizedBox(height: 12),
              PrimaryButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/auth/success'),
                label: 'Reset Password',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
