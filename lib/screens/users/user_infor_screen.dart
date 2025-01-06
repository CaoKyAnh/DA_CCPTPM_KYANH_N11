// user_infor_screen.dart
import 'package:final_project_rent_moto_fe/widgets/users/user_infor_body.dart';
import 'package:flutter/material.dart';

class UserInforScreen extends StatelessWidget {
  const UserInforScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: UserInforBody(), // Gọi widget UserInforBody
    );
  }
}
