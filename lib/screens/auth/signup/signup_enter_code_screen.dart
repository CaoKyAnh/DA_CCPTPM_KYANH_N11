import 'package:final_project_rent_moto_fe/widgets/auth/signup/sigunup_enter_code/signup_enter_code_body.dart';
import 'package:final_project_rent_moto_fe/widgets/auth/signup/sigunup_enter_code/signup_enter_code_header.dart';
import 'package:flutter/material.dart';

class SignupEnterCodeScreen extends StatefulWidget {
  final String email; // Thêm biến email

  const SignupEnterCodeScreen(
      {super.key, required this.email}); // Cập nhật constructor

  @override
  State<SignupEnterCodeScreen> createState() => _SignupEnterCodeScreenState();
}

class _SignupEnterCodeScreenState extends State<SignupEnterCodeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Bước 2',
          style: TextStyle(
              fontWeight: FontWeight.w700, color: Colors.white, fontSize: 30),
        ),
        backgroundColor: const Color(0xFFFFAD15),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 150, child: SignupEnterCodeHeader()),
          SignupEnterCodeBody(email: widget.email), // Truyền email vào
        ],
      ),
    );
  }
}
