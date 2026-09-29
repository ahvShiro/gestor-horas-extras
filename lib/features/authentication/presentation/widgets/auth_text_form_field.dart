import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthTextFormField extends StatelessWidget {
  const AuthTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.inputFormatters,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final String? Function(String? value) validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      enabled: enabled,
      validator: validator,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: labelText,
        hintText: hintText,
      ),
    );
  }
}
