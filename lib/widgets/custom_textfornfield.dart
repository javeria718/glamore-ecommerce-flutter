import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextEditingController controller;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final String? helperText;

  const CustomTextFormField({
    super.key,
    required this.label,
    required this.icon,
    required this.keyboardType,
    required this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
    this.helperText,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: widget.helperText,
        helperStyle: TextStyle(
          color: Colors.black.withValues(alpha: 0.56),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelStyle: const TextStyle(color: Colors.black54),
        floatingLabelStyle: const TextStyle(color: Colors.teal),
        prefixIcon: Icon(widget.icon, color: Colors.black54),
        suffixIcon: widget.suffixIcon,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.55),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.90)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.90)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.teal, width: 1.8),
        ),
      ),
    );
  }
}
