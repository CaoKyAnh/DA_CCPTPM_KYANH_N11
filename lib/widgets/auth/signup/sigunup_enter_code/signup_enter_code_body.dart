import 'dart:async';

import 'package:final_project_rent_moto_fe/services/auth/sendmail_service.dart';
import 'package:final_project_rent_moto_fe/services/auth/signup_service.dart';
import 'package:final_project_rent_moto_fe/services/auth/validator_service.dart';
import 'package:final_project_rent_moto_fe/widgets/auth/button_auth.dart';
import 'package:final_project_rent_moto_fe/widgets/auth/text_field_username_auth.dart';
import 'package:flutter/material.dart';

class SignupEnterCodeBody extends StatefulWidget {
  final String email; // Thêm biến email

  const SignupEnterCodeBody(
      {super.key, required this.email}); // Cập nhật constructor để nhận email

  @override
  State<SignupEnterCodeBody> createState() => _SignupEnterCodeBodyState();
}

class _SignupEnterCodeBodyState extends State<SignupEnterCodeBody> {
  final _controllerCode = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _validatorService = ValidatorService();
  final _sendmailService = SendMailService();
  final _signupService = SignupService();
  int _seconds = 60;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (time) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(
            height: 150,
          ),
          TextFieldUsernameAuth(
            controller: _controllerCode,
            label: "Mã xác thực",
            hintText: "Nhập mã xác thực",
            icon: const Icon(Icons.verified),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Mã xác thực không được trống!';
              } else if (!_validatorService.isValidCode(value)) {
                return 'Mã xác thực phải là những ký tự in hoa';
              }
              return null; // Nếu không có lỗi
            },
            readOnly: false,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 5, bottom: 15),
            child: Row(
              children: [
                const SizedBox(
                  width: 30,
                ),
                const Text(
                  'Gửi lại mã: ',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                _seconds > 0
                    ? Text(
                        '$_seconds s',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      )
                    : TextButton(
                        style: ButtonStyle(
                          // Bỏ padding
                          padding: WidgetStateProperty.all<EdgeInsets>(
                              EdgeInsets.zero),
                          // Bỏ kích thước mặc định
                          minimumSize:
                              WidgetStateProperty.all(const Size(0, 0)),
                          // Thu gọn vùng nhấn
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          setState(() {
                            _seconds = 60; // Reset lại thời gian đếm ngược
                            startTimer();
                            // Bắt đầu lại Timer
                          });
                          _sendmailService.sendCodeByMail(
                              context, widget.email);
                        },
                        child: const Text(
                          "Gửi",
                          style: TextStyle(
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                              fontSize: 18),
                        ),
                      ),
              ],
            ),
          ),
          ButtonAuth(
            text: "TIẾP TỤC",
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _signupService.verifyCode(
                    widget.email, _controllerCode.text.trim(), context);
              }
            },
          )
        ],
      ),
    );
  }
}
