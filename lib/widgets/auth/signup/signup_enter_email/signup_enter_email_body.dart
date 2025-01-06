import 'package:final_project_rent_moto_fe/screens/auth/signup/signup_enter_code_screen.dart';
import 'package:final_project_rent_moto_fe/services/auth/sendmail_service.dart';
import 'package:final_project_rent_moto_fe/services/auth/signup_service.dart';
import 'package:final_project_rent_moto_fe/services/auth/validator_service.dart';
import 'package:final_project_rent_moto_fe/widgets/auth/button_auth.dart';
import 'package:final_project_rent_moto_fe/widgets/auth/text_field_username_auth.dart';
import 'package:final_project_rent_moto_fe/widgets/notification/error_notification.dart';
import 'package:flutter/material.dart';

class SignupEnterEmailBody extends StatefulWidget {
  const SignupEnterEmailBody({super.key});

  @override
  State<SignupEnterEmailBody> createState() => _SignupEnterEmailBodyState();
}

class _SignupEnterEmailBodyState extends State<SignupEnterEmailBody> {
  final _controllerUserName = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _validatorService = ValidatorService();
  final SendMailService _sendMailService = SendMailService();
  final SignupService _signupService = SignupService();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 150),
          TextFieldUsernameAuth(
            controller: _controllerUserName,
            label: "Email",
            hintText: "Nhập email",
            icon: const Icon(Icons.email_outlined),
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
          const SizedBox(height: 20),
          ButtonAuth(
            text: "TIẾP TỤC",
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                // Kiểm tra nếu người dùng đã tồn tại
                bool userExists = await _signupService
                    .checkIfUserExists(_controllerUserName.text.trim());

                if (!userExists) {
                  // Gửi mã xác minh nếu người dùng không tồn tại
                  await _sendMailService.sendCodeByMail(
                    context,
                    _controllerUserName.text.trim(),
                  );

                  // Chuyển sang trang tiếp theo sau khi gửi mã xác minh
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignupEnterCodeScreen(
                        email: _controllerUserName.text.trim(),
                      ),
                    ),
                  );
                } else {
                  // Hiển thị thông báo lỗi nếu người dùng đã tồn tại
                  ScaffoldMessenger.of(context).showSnackBar(
                    const ErrorNotification(text: "Email đã tồn tại")
                        .buildSnackBar(),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
