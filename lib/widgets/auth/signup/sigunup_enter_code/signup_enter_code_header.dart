import 'package:flutter/material.dart';

class SignupEnterCodeHeader extends StatefulWidget {
  const SignupEnterCodeHeader({super.key});

  @override
  State<SignupEnterCodeHeader> createState() => _SignupEnterCodeHeaderState();
}

class _SignupEnterCodeHeaderState extends State<SignupEnterCodeHeader> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -650,
          left: -200,
          child: Container(
            width: 900,
            height: 800,
            decoration: const BoxDecoration(
              color: Color(0xFFFFAD15),
              shape: BoxShape.circle,
            ),
          ),
        ),
        const Positioned(
          top: 0,
          right: 30,
          child: Text(
            'Tạo',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Colors.white,
            ),
          ),
        ),
        const Positioned(
          top: 30, // Điều chỉnh vị trí của văn bản
          right: 90, // Điều chỉnh vị trí của văn bản
          child: Text(
            'Tài Khoản!',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Colors.white, // Màu sắc của văn bản
            ),
          ),
        ),
        const Positioned(
          top: 100, // Điều chỉnh vị trí của văn bản
          right: 20, // Điều chỉnh vị trí của văn bản
          child: Text(
            'Nhập mã để tiếp tục!',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white, // Màu sắc của văn bản
            ),
          ),
        ),
      ],
    );
  }
}
