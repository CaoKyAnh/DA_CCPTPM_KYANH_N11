import 'package:final_project_rent_moto_fe/services/auth/validator_service.dart';
import 'package:final_project_rent_moto_fe/widgets/auth/button_auth.dart';
import 'package:final_project_rent_moto_fe/widgets/auth/text_field_username_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final controllerEmail = TextEditingController();
  final _validatorService = ValidatorService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Quên mật khẩu",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 25),
        ),
        backgroundColor: Color(0xFFFFAD15),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 50),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Image.asset("assets/images/logo.png"),
            ),
            TextFieldUsernameAuth(
              controller: controllerEmail,
              label: "Email",
              hintText: "Nhập email",
              icon: Icon(Icons.email_outlined),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email không được trống!';
                } else if (!_validatorService.isValidEmail(value)) {
                  return 'Định dạng email không đúng';
                }
                return null;
              },
              readOnly: false,
            ),
            SizedBox(
              height: 20,
            ),
            ButtonAuth(text: "TIẾP TỤC", onPressed: () {})
          ],
        ),
      ),
    );
  }
}
