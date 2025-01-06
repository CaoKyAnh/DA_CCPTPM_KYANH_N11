import 'package:final_project_rent_moto_fe/widgets/notification/error_notification.dart';
import 'package:final_project_rent_moto_fe/widgets/notification/success_notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingService {
  Future<void> updatePassword(
      String currentPassword, String newPassword, BuildContext context) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        final String email = currentUser.email!;
        final credential = EmailAuthProvider.credential(
            email: email, password: currentPassword);

        // Thực hiện xác thực lại mật khẩu cũ
        await currentUser.reauthenticateWithCredential(credential);

        // Cập nhật mật khẩu mới
        await currentUser.updatePassword(newPassword);
        ScaffoldMessenger.of(context).showSnackBar(
          const SuccessNotification(text: "Cập nhật mật khẩu thành công.")
              .buildSnackBar(),
        );
      } on FirebaseAuthException catch (e) {
        // Kiểm tra lỗi chi tiết và hiển thị thông báo lỗi
        if (e.code == 'wrong-password') {
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const ErrorNotification(text: "Mật khẩu cũ không đúng.")
                .buildSnackBar(),
          );
        }
      } catch (e) {
        // Bắt lỗi ngoài FirebaseAuthException
        print('Lỗi không xác định: $e');
      }
    }
  }
}
