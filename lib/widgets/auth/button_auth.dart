import 'package:flutter/material.dart';

class ButtonAuth extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  const ButtonAuth({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Colors.grey,
              Color(0xFFFFAD15),
            ],
          ),
          borderRadius: BorderRadius.circular(8)),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
