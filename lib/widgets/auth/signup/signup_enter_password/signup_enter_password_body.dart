import 'package:final_project_rent_moto_fe/screens/auth/signup/signup_enter_info_screen.dart';
import 'package:final_project_rent_moto_fe/services/auth/signup_service.dart';
import 'package:final_project_rent_moto_fe/widgets/notification/error_notification.dart';
import 'package:final_project_rent_moto_fe/widgets/notification/success_notification.dart';
import 'package:flutter/material.dart';
import 'package:final_project_rent_moto_fe/services/auth/validator_service.dart';
import 'package:final_project_rent_moto_fe/widgets/auth/button_auth.dart';
import 'package:final_project_rent_moto_fe/widgets/auth/text_field_password_auth.dart';

class SignupEnterPasswordBody extends StatefulWidget {
  final String email;
  const SignupEnterPasswordBody({super.key, required this.email});

  @override
  State<SignupEnterPasswordBody> createState() =>
      _SignupEnterPasswordBodyState();
}

class _SignupEnterPasswordBodyState extends State<SignupEnterPasswordBody> {
  final _controllerUsername = TextEditingController();
  final _controllerPassword = TextEditingController();
  final _controllerPasswordCF = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _validatorService = ValidatorService();
  final _signupService = SignupService();
  bool _obscureText = true;
  bool _obscureTextCF = true;
  @override
  void initState() {
    super.initState();
    setState(() {
      _controllerUsername.text = widget.email;
    });
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
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 20),
            child: Container(
              decoration: const BoxDecoration(),
              child: TextFormField(
                controller: _controllerUsername,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  label: Text(
                    "Nhập mật khẩu cho email",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          TextFieldPasswordAuth(
            controller: _controllerPassword,
            label: 'Mật khẩu',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Mật khẩu không được trống!';
              } else if (!_validatorService.isValidPassword(value)) {
                return 'Mật khẩu phải trên 8 ký tự. Gồm 1 chữ hoa, chữ thường và số.';
              }
              return null;
            },
            hintText: 'Nhập mật khẩu',
            obscureText: _obscureText,
            readOnly: false,
            toggleObscureText: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
          const SizedBox(
            height: 10,
          ),
          TextFieldPasswordAuth(
            controller: _controllerPasswordCF,
            label: 'Nhập lại mật khẩu',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Mật khẩu xác thực không được trống!';
              } else if (!_validatorService.isValidPassword(value)) {
                return 'Mật khẩu phải trên 8 ký tự. Gồm 1 chữ hoa, chữ thường và số.';
              }
              return null;
            },
            hintText: 'Nhập lại mật khẩu',
            obscureText: _obscureTextCF,
            readOnly: false,
            toggleObscureText: () {
              setState(() {
                _obscureTextCF = !_obscureTextCF;
              });
            },
          ),
          const SizedBox(
            height: 20,
          ),
          ButtonAuth(
            text: "TIẾP TỤC",
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (_controllerPassword.text.trim() ==
                    _controllerPasswordCF.text.trim()) {
                  _signupService.register(
                      context,
                      _controllerUsername.text.trim(),
                      _controllerPassword.text.trim());
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SuccessNotification(
                              text: "Cập nhật mật khẩu thành công.")
                          .buildSnackBar());
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SignupEnterInfoScreen(email: widget.email),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const ErrorNotification(
                              text: "Mật khẩu nhập lại không đúng.")
                          .buildSnackBar());
                }
              }
            },
          )
        ],
      ),
    );
  }
}
