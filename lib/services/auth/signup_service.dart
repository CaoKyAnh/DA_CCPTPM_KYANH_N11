import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_rent_moto_fe/screens/auth/signup/signup_enter_password_screen.dart';
import 'package:final_project_rent_moto_fe/widgets/notification/error_notification.dart';
import 'package:flutter/material.dart';

class SignupService {
  final String baseUrlAuth = 'http://10.0.2.2:3000/api/auth';
  final String baseUrlUser = 'http://10.0.2.2:3000/api/appUser';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<bool> checkIfUserExists(String email) async {
    try {
      // Query Firestore to check if the email exists in the 'users' collection
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      // If any document is found, the user exists
      return querySnapshot.docs.isNotEmpty;
    } catch (error) {
      throw Exception('Error checking user existence: $error');
    }
  }

  Future<void> verifyCode(
      String email, String enteredCode, BuildContext context) async {
    try {
      // Lấy tài liệu từ Firestore
      DocumentSnapshot document = await FirebaseFirestore.instance
          .collection('verificationSignupCodes')
          .doc(email)
          .get();

      if (document.exists) {
        // Ép kiểu dữ liệu để truy cập vào các phần tử
        Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
        String? verificationCode = data?['verificationCode'];
        DateTime expirationTime =
            (data?['expirationTime'] as Timestamp).toDate();

        // Kiểm tra mã xác minh và thời gian hết hạn
        if (verificationCode == enteredCode) {
          if (DateTime.now().isBefore(expirationTime)) {
            // Chuyển tới trang SignupScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => SignupEnterPasswordScreen(
                        eamil: email,
                      )),
            );
          } else {
            // Thông báo mã đã hết hạn
            ScaffoldMessenger.of(context).showSnackBar(
              const ErrorNotification(text: "Code has expired.")
                  .buildSnackBar(),
            );
          }
        } else {
          // Thông báo mã xác minh không đúng
          ScaffoldMessenger.of(context).showSnackBar(
            const ErrorNotification(text: "Code is incorrect.").buildSnackBar(),
          );
        }
      } else {
        // Thông báo không tìm thấy tài liệu
        ScaffoldMessenger.of(context).showSnackBar(
          const ErrorNotification(text: "Code does not exist.").buildSnackBar(),
        );
      }
    } catch (e) {
      // Xử lý lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi: $e')),
      );
    }
  }

  Future<Map<String, dynamic>> register(
      BuildContext context, String email, String password) async {
    final url = Uri.parse('$baseUrlAuth/'); // endpoint cho đăng ký
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'email': email,
      'password': password,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        // Đăng ký thành công
        return jsonDecode(response.body);
      } else {
        // Xử lý lỗi khi đăng ký thất bại
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (error) {
      throw Exception('Error during registration: $error');
    }
  }

  // Cập nhật thông tin người dùng
  Future<Map<String, dynamic>> updateUser({
    required String email,
    required String phoneNumber,
    required String name,
    required String dayOfBirth,
    required String gplx,
  }) async {
    final url = Uri.parse(
        '$baseUrlUser/$email'); // endpoint cho việc cập nhật thông tin người dùng
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'phoneNumber': phoneNumber,
      'information': {
        'name': name,
        'dayOfBirth': dayOfBirth,
        'gplx': gplx,
      }
    });

    try {
      // Gửi yêu cầu PATCH để cập nhật thông tin người dùng
      final response = await http.patch(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // Cập nhật thành công
        return jsonDecode(response.body);
      } else {
        // Xử lý lỗi nếu cập nhật thất bại
        final error = jsonDecode(response.body);
        throw Exception(
            error['message'] ?? 'Failed to update user information');
      }
    } catch (error) {
      throw Exception('Error updating user: $error');
    }
  }

  // Hàm updateAvatar để cập nhật ảnh đại diện
  Future<Map<String, dynamic>> updateAvatar({
    required String email,
    required String avatarUrl,
  }) async {
    final url = Uri.parse(
        '$baseUrlUser/$email'); // endpoint cho việc cập nhật ảnh đại diện
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'information': {
        'avatar': avatarUrl, // URL hoặc đường dẫn ảnh đại diện mới
      }
    });

    try {
      // Gửi yêu cầu PUT để cập nhật ảnh đại diện người dùng
      final response = await http.patch(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // Cập nhật thành công
        return jsonDecode(response.body);
      } else {
        // Xử lý lỗi nếu cập nhật thất bại
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update avatar');
      }
    } catch (error) {
      throw Exception('Error updating avatar: $error');
    }
  }
}
