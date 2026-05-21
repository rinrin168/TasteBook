import 'package:flutter/material.dart';
import 'package:app/core/theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
  });

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style:
          FilledButton.styleFrom(
            backgroundColor: TasteBookColors.cocoa,
            foregroundColor: TasteBookColors.white,
            minimumSize: const Size.fromHeight(52),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: const StadiumBorder(),
            elevation: 2,
            shadowColor: TasteBookColors.cocoa.withValues(alpha: 0.18),
          ).merge(
            ButtonStyle(
              side: WidgetStatePropertyAll(
                BorderSide(
                  color: TasteBookColors.tan.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
            ),
          ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
