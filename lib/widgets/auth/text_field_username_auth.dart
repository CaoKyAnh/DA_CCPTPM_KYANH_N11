import 'package:flutter/material.dart';

class TextFieldUsernameAuth extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final Icon icon;
  final String? Function(String?)? validator;
  final bool readOnly;
  const TextFieldUsernameAuth({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    required this.validator,
    required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFA500).withOpacity(0.5),
            offset: const Offset(-2, -2),
            blurRadius: 15,
          ),
          BoxShadow(
            color: const Color(0xFFDA70D6).withOpacity(0.5),
            offset: const Offset(2, 2),
            blurRadius: 15,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: Colors.black.withOpacity(0.8),
              fontWeight: FontWeight.w500),
          hintText: hintText,
          border: const OutlineInputBorder(borderSide: BorderSide.none),
          suffixIcon: icon,
        ),
      ),
    );
  }
}
