import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_rent_moto_fe/widgets/notification/error_notification.dart';
import 'package:final_project_rent_moto_fe/widgets/notification/success_notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class SendMailService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Hàm sinh mã xác thực ngẫu nhiên
  String generateVerificationCode() {
    const length = 6;
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return String.fromCharCodes(
      Iterable.generate(
          length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  Future<void> sendReasonByMail(
      BuildContext context, String email, String reason) async {
    try {
      // Cấu hình thông tin email
      String username = 'caokyanh122@gmail.com'; // Thay thế bằng email của bạn
      String appPassword =
          'wypb fhgx synr nkty'; // Thay thế bằng mật khẩu ứng dụng
      final smtpServer = gmail(username, appPassword);

      final message = Message()
        ..from = Address(username, 'RentMoto')
        ..recipients.add(email)
        ..subject = 'Thông báo từ chối duyệt xe'
        ..html = """
        <html>
          <body style="font-family: Arial, sans-serif; padding: 20px; background-color: #f4f4f4;">
            <div style="max-width: 600px; margin: auto; padding: 20px; border-radius: 8px; background-color: #FF5733; box-shadow: 0 4px 8px rgba(0,0,0,0.1);">
              <h2 style="color: #ffffff;">Xin chào!</h2>
              <p style="font-size: 16px; color: #ffffff;">Chúng tôi rất tiếc phải thông báo rằng bài đăng của bạn đã bị từ chối.</p>
              <div style="font-size: 16px; color: #ffffff; margin-top: 10px;">
                <strong>Lý do:</strong>
                <p style="background-color: #333; color: #ffffff; padding: 10px; border-radius: 5px;">
                  $reason
                </p>
              </div>
              <p style="font-size: 16px; color: #ffffff; margin-top: 20px;">
                Nếu bạn có bất kỳ thắc mắc nào, vui lòng liên hệ với chúng tôi.
              </p>
            </div>
          </body>
        </html>
      """;

      // Gửi email
      await send(message, smtpServer);

      // Thông báo gửi thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SuccessNotification(text: "Đã gửi mail thành công").buildSnackBar(),
      );
    } catch (e) {
      // Xử lý lỗi khi gửi email
      ScaffoldMessenger.of(context).showSnackBar(
        ErrorNotification(text: 'Error: $e').buildSnackBar(),
      );
    }
  }

  Future<void> sendCodeByMail(BuildContext context, String email) async {
    try {
      // Kiểm tra xem email có tồn tại bằng cách tạo một tài khoản tạm thời
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: 'temporary_password', // Mật khẩu tạm thời để kiểm tra email
      );

      // Nếu tạo tài khoản thành công, xóa ngay lập tức vì đây là kiểm tra
      await userCredential.user?.delete();

      // Sinh mã xác thực và cấu hình gửi email
      String verificationCode = generateVerificationCode();
      String username = 'caokyanh122@gmail.com'; // Thay thế bằng email của bạn
      String appPassword =
          'wypb fhgx synr nkty'; // Thay thế bằng mật khẩu ứng dụng
      final smtpServer = gmail(username, appPassword);

      // Tính toán thời gian hết hạn của mã (3 phút sau thời gian hiện tại)
      DateTime expirationTime = DateTime.now().add(const Duration(minutes: 3));

      final message = Message()
        ..from = Address(username, 'RentMoto')
        ..recipients.add(email)
        ..subject = 'Mã xác thực của bạn'
        ..html = """
        <html>
          <body style="font-family: Arial, sans-serif; padding: 20px; background-color: #f4f4f4;">
            <div style="max-width: 600px; margin: auto; padding: 20px; border-radius: 8px; background-color: #FFAD15FF; box-shadow: 0 4px 8px rgba(0,0,0,0.1);">
              <h2 style="color: #ffffff;">Xin chào!</h2>
              <p style="font-size: 16px; color: #ffffff;">Mã xác thực của bạn là:</p>
              <div style="
                font-size: 24px;
                font-weight: bold;
                color: #ffffff;
                background-color: #333;
                padding: 15px;
                border-radius: 5px;
                text-align: center;
                margin: 10px 0;
              ">
                $verificationCode
              </div>
              <p style="font-size: 16px; color: #ffffff; margin-top: 20px;">
                Vui lòng nhập mã này để tiếp tục xác thực tài khoản của bạn.
              </p>
              <p style="font-size: 14px; color: #e0e0e0;">Nếu bạn không yêu cầu mã này, vui lòng bỏ qua email này.</p>
            </div>
          </body>
        </html>
      """;

      // Gửi email và lưu mã xác thực vào Firestore
      await send(message, smtpServer);
      await FirebaseFirestore.instance
          .collection('verificationSignupCodes')
          .doc(email)
          .set({
        'verificationCode': verificationCode,
        'expirationTime': expirationTime,
        'createdAt': DateTime.now(),
      }, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(
        SuccessNotification(text: "The code has been sent to your email.")
            .buildSnackBar(),
      );
      // Thông báo gửi thành công
    } on FirebaseAuthException catch (e) {
      // Xử lý lỗi Firebase liên quan đến email
      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Email đã được sử dụng!';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Email không hợp lệ!';
      } else {
        errorMessage = 'Đã xảy ra lỗi: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      // Xử lý lỗi khi gửi email
      ErrorNotification(text: 'Error: $e');
    }
  }
}
