import 'package:final_project_rent_moto_fe/services/auth/signup_service.dart';
import 'package:final_project_rent_moto_fe/services/auth/validator_service.dart';
import 'package:final_project_rent_moto_fe/services/setting/setting_service.dart';
import 'package:final_project_rent_moto_fe/widgets/auth/button_auth.dart';
import 'package:final_project_rent_moto_fe/widgets/auth/text_field_password_auth.dart';
import 'package:final_project_rent_moto_fe/widgets/notification/error_notification.dart';
import 'package:flutter/material.dart';

class UserInforChangePassword extends StatefulWidget {
  final String email;
  const UserInforChangePassword({super.key, required this.email});

  @override
  State<UserInforChangePassword> createState() =>
      _UserInforChangePasswordState();
}

class _UserInforChangePasswordState extends State<UserInforChangePassword> {
  final _controllerPassword = TextEditingController();
  final _controllerPasswordCF = TextEditingController();
  final _controllerPasswordOld = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Đảm bảo có FormKey
  final _validatorService = ValidatorService();
  final _settingService = SettingService();
  bool _obscureTextOld = true;
  bool _obscureText = true;
  bool _obscureTextCF = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Đổi mật khẩu"),
        backgroundColor: const Color(0xFFF49C21),
        centerTitle: true,
      ),
      body: Form(
        // Bao bọc trong Form widget
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 30),
            TextFieldPasswordAuth(
              controller: _controllerPasswordOld,
              label: 'Mật khẩu cũ',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Mật khẩu cũ không được trống!';
                } else if (!_validatorService.isValidPassword(value)) {
                  return 'Mật khẩu phải trên 8 ký tự. Gồm 1 chữ hoa, chữ thường và số.';
                }
                return null;
              },
              hintText: 'Nhập mật khẩu cũ',
              obscureText: _obscureTextOld,
              readOnly: false,
              toggleObscureText: () {
                setState(() {
                  _obscureTextOld = !_obscureTextOld;
                });
              },
            ),
            const SizedBox(height: 10),
            TextFieldPasswordAuth(
              controller: _controllerPassword,
              label: 'Mật khẩu mới',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Mật khẩu không được trống!';
                } else if (!_validatorService.isValidPassword(value)) {
                  return 'Mật khẩu phải trên 8 ký tự. Gồm 1 chữ hoa, chữ thường và số.';
                }
                return null;
              },
              hintText: 'Nhập mật khẩu mới',
              obscureText: _obscureText,
              readOnly: false,
              toggleObscureText: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 20),
            ButtonAuth(
              text: "TIẾP TỤC",
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (_controllerPassword.text.trim() ==
                      _controllerPasswordCF.text.trim()) {
                    // Kiểm tra mật khẩu mới không trùng với mật khẩu cũ
                    if (_controllerPassword.text.trim() ==
                        _controllerPasswordOld.text.trim()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const ErrorNotification(
                                text:
                                    "Mật khẩu mới không được trùng với mật khẩu cũ.")
                            .buildSnackBar(),
                      );
                    } else {
                      // Logic để xử lý đổi mật khẩu
                      _settingService.updatePassword(
                          _controllerPasswordOld.text.trim(),
                          _controllerPassword.text.trim(),
                          context);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const ErrorNotification(
                              text: "Mật khẩu nhập lại không đúng.")
                          .buildSnackBar(),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
