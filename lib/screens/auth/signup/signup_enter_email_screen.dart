import 'package:final_project_rent_moto_fe/widgets/auth/signup/signup_enter_email/signup_enter_email_body.dart';
import 'package:final_project_rent_moto_fe/widgets/auth/signup/signup_enter_email/signup_enter_email_header.dart';
import 'package:flutter/material.dart';

class SignupEnterEmailScreen extends StatefulWidget {
  const SignupEnterEmailScreen({super.key});

  @override
  State<SignupEnterEmailScreen> createState() => _SignupEnterEmailScreenState();
}

class _SignupEnterEmailScreenState extends State<SignupEnterEmailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Bước 1',
          style: TextStyle(
              fontWeight: FontWeight.w700, color: Colors.white, fontSize: 30),
        ),
        backgroundColor: const Color(0xFFFFAD15),
      ),
      body: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 150,
            child: SignupEnterEmailHeader(),
          ),
          SignupEnterEmailBody(),
        ],
      ),
    );
  }
}
