import 'package:final_project_rent_moto_fe/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:final_project_rent_moto_fe/widgets/auth/signup/signup_change_avatar/signup_chang_avatar_infor.dart';
import 'package:final_project_rent_moto_fe/widgets/auth/signup/signup_change_avatar/signup_change_avatar_main.dart';

class SignupChangeAvatarBody extends StatefulWidget {
  final String email;
  const SignupChangeAvatarBody({super.key, required this.email});

  @override
  State<SignupChangeAvatarBody> createState() => _SignupChangeAvatarBodyState();
}

class _SignupChangeAvatarBodyState extends State<SignupChangeAvatarBody> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: const Color.fromARGB(133, 240, 239, 239),
      child: Column(
        children: [
          const SizedBox(
            height: 100,
          ),
          SignupChangeAvatarMain(
            email: widget.email,
          ),
          const SizedBox(
            height: 30,
          ),
          SignupChangAvatarInfor(
            email: widget.email,
          ),
          const SizedBox(
            height: 100,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Dashboard(
                        initialIndex: 2), // Chỉ số UserInforScreen
                  ),
                );
              },
              child: const Text(
                "Bỏ qua",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 20),
              ),
            ),
          )
        ],
      ),
    );
  }
}
