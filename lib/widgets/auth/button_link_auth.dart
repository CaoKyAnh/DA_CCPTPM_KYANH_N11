import 'package:flutter/material.dart';

class ButtonLinkAuth extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const ButtonLinkAuth(
      {super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: onPressed,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w700,
              fontSize: 25,
            ),
          ),
        ),
        const SizedBox(
          width: 50,
        ),
      ],
    );
  }
}
