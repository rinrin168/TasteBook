import 'package:flutter/material.dart';
import 'package:app/core/theme.dart';
import '../widgets/auth_card.dart';
import '../widgets/buttons.dart';

class AuthSuccessScreen extends StatelessWidget {
  const AuthSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final title = args?['title'] as String? ?? 'Success';
    final message = args?['message'] as String?;
    final buttonLabel = args?['buttonLabel'] as String? ?? 'Go to Home';
    final onPressedRoute = args?['onPressedRoute'] as String? ?? '/home';
    final iconData = args?['icon'] as IconData? ?? Icons.check_circle_outline;

    return Scaffold(
      backgroundColor: TasteBookColors.tan,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AuthCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    iconData,
                    size: 84,
                    color: TasteBookColors.cocoa,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: TasteBookColors.espresso,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: TasteBookColors.espresso.withValues(alpha: 0.85),
                            height: 1.4,
                          ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  PrimaryButton(
                    onPressed: () =>
                        Navigator.of(context).pushReplacementNamed(onPressedRoute),
                    label: buttonLabel,
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
