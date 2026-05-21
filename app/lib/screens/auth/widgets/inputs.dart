import 'package:flutter/material.dart';
import 'package:app/core/theme.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    this.controller,
    this.hint,
    this.keyboardType,
    this.obscure = false,
  });

  final TextEditingController? controller;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: TasteBookColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}
