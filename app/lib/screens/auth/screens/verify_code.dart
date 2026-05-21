import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/core/theme.dart';
import '../widgets/auth_card.dart';
import '../widgets/buttons.dart';

class VerifyCodeScreen extends StatelessWidget {
  const VerifyCodeScreen({
    super.key,
    required this.title,
    required this.description,
    required this.confirmLabel,
    required this.onConfirmedRoute,
  });

  final String title;
  final String description;
  final String confirmLabel;
  final String onConfirmedRoute;

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
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: TasteBookColors.espresso,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: TasteBookColors.espresso.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(6, (i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: SizedBox(
                        width: 46,
                        height: 56,
                        child: TextField(
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: TasteBookColors.espresso,
                                fontWeight: FontWeight.w700,
                              ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: TasteBookColors.white,
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(1),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                onPressed: () => Navigator.of(
                  context,
                ).pushReplacementNamed(onConfirmedRoute),
                label: confirmLabel,
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: TasteBookColors.cocoa,
                  ),
                  child: const Text("Didn't get verification code? Resend"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
