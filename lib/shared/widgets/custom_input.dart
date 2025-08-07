import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final String? Function(String?)? validator;

  const CustomInput({
    super.key,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white), // ✅ texto blanco
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.orangeAccent, width: 2),
        ),
      ),
      style: const TextStyle(
        color: Colors.white,
      ), // ✅ texto ingresado en blanco
    );
  }
}
