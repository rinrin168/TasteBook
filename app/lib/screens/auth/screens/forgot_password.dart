import 'package:flutter/material.dart';
import 'package:app/core/theme.dart';
import '../widgets/auth_card.dart';
import '../widgets/inputs.dart';
import '../widgets/buttons.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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
                    'Forgot Password',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: TasteBookColors.espresso,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Enter your email to receive a reset code and get back to your recipes.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: TasteBookColors.espresso.withValues(alpha: 0.85),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              const AuthTextField(
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed('/auth/verify-reset'),
                label: 'Send reset code',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
