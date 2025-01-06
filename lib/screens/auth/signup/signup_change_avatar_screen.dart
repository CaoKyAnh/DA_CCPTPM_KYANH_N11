import 'package:flutter/material.dart';
import 'package:final_project_rent_moto_fe/widgets/auth/signup/signup_change_avatar/signup_change_avatar_body.dart';

class SignupChangeAvatarScreen extends StatefulWidget {
  final String email;

  const SignupChangeAvatarScreen({
    super.key,
    required this.email,
  });

  @override
  State<SignupChangeAvatarScreen> createState() =>
      _SignupChangeAvatarScreenState();
}

class _SignupChangeAvatarScreenState extends State<SignupChangeAvatarScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thêm ảnh đại điện',
          style: TextStyle(
              fontWeight: FontWeight.w700, color: Colors.white, fontSize: 30),
        ),
        backgroundColor: const Color(0xFFFFAD15),
      ),
      body: SignupChangeAvatarBody(
        email: widget.email,
      ),
    );
  }
}
