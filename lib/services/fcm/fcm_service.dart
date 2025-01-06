// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class FCMService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> storeFcmTokenForMotorcycleOwner() async {
    // Get the FCM token
    String? token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      // Get the current user's email
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final String email = currentUser.email!;

        try {
          // Send the FCM token and email to the backend API
          final response = await http.patch(
            Uri.parse(
                'http://10.0.2.2:3000/api/fcm/add'), // Replace with your backend URL
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'fcmToken': token,
              'email': email,
            }),
          );

          if (response.statusCode == 200) {
            print('FCM Token đã được lưu thành công.');
          } else {
            print('Không thể lưu FCM Token. Lỗi: ${response.body}');
          }
        } catch (e) {
          print('Lỗi khi gửi FCM Token đến backend: $e');
        }
      }
    } else {
      print('Không thể lấy FCM Token');
    }
  }

  Future<void> removeFcmTokenOnSignOut() async {
    try {
      // Get the current user's email
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final String email = currentUser.email!;

        final response = await http.delete(
          Uri.parse('http://10.0.2.2:3000/api/fcm/$email'),
          headers: {
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          print('FCM Token đã được xóa thành công.');
        } else {
          print('Không thể xóa FCM Token. Lỗi: ${response.body}');
        }
      }
    } catch (e) {
      print('Lỗi khi xóa FCM Token: $e');
    }
  }

  void initializeFCM() {
    // Store the initial token locally
    storeFcmTokenForMotorcycleOwner();

    // Listen for token changes
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print("FCM Token đã thay đổi: $newToken");

      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        try {
          // Call the function to store the token both locally and on the backend
          await storeFcmTokenForMotorcycleOwner(); // This should now handle both actions

          print('FCM Token đã được cập nhật thành công');
        } catch (e) {
          print('Lỗi khi cập nhật FCM Token: $e');
        }
      }
    });
  }

  Future<String> getFcmTokenForOwner(String email) async {
    try {
      // Send a request to the backend to fetch the FCM token
      final response = await http.get(
        Uri.parse(
            'http://10.0.2.2:3000/api/fcm/$email'), // Replace with your backend URL
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // If the request is successful, return the FCM token from the response
        final data = json.decode(response.body);
        return data['fcmToken'] ?? '';
      } else {
        print('Không thể lấy FCM Token. Lỗi: ${response.body}');
        return '';
      }
    } catch (e) {
      print('Lỗi khi lấy FCM Token: $e');
      return '';
    }
  }

  Future<void> sendPushNotification(String fcmToken, String title,
      String message, String email, String screen) async {
    const String backendEndpoint = 'http://10.0.2.2:3000/api/send-notification';

    try {
      final response = await http.post(
        Uri.parse(backendEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'fcmToken': fcmToken,
          'notification': {
            'title': title,
            'body': message,
          },
          'accountInfo': {
            'email': email,
          },
          'screen': screen, // Thêm màn hình vào dữ liệu gửi đi
        }),
      );

      if (response.statusCode == 200) {
        print('Push notification sent successfully');
      } else {
        print(
            'Failed to send push notification: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error sending push notification: $e');
    }
  }
}
