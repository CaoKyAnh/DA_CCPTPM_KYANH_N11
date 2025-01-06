import 'package:flutter/material.dart';
import 'package:final_project_rent_moto_fe/widgets/auth/signup/signup_enter_password/signup_enter_password_body.dart';
import 'package:final_project_rent_moto_fe/widgets/auth/signup/signup_enter_password/signup_enter_password_header.dart';

class SignupEnterPasswordScreen extends StatefulWidget {
  final String eamil;
  const SignupEnterPasswordScreen({super.key, required this.eamil});

  @override
  State<SignupEnterPasswordScreen> createState() =>
      _SignupEnterPasswordScreenState();
}

class _SignupEnterPasswordScreenState extends State<SignupEnterPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Bước 3',
          style: TextStyle(
              fontWeight: FontWeight.w700, color: Colors.white, fontSize: 30),
        ),
        backgroundColor: const Color(0xFFFFAD15),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 150,
            child: SignupEnterPasswordHeader(),
          ),
          SignupEnterPasswordBody(
            email: widget.eamil,
          ),
        ],
      ),
    );
  }
}
