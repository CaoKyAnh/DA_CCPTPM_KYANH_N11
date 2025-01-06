// ignore_for_file: avoid_print, unused_element

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:final_project_rent_moto_fe/screens/dashboard.dart';
import 'package:final_project_rent_moto_fe/screens/admin/admin_screen.dart';
import 'package:final_project_rent_moto_fe/screens/notification/notification_list_screen.dart';
import 'package:final_project_rent_moto_fe/services/fcm/fcm_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Đảm bảo Flutter đã được khởi tạo
  await Firebase.initializeApp();

  final FCMService fcmService = FCMService();
  fcmService.initializeFCM();
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      print('Message Title: ${message.notification?.title}');
      print('Message Body: ${message.notification?.body}');
      // Gọi hiển thị notification bằng flutter_local_notifications
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? _homeScreen;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _checkUserRole(); // Kiểm tra role và cập nhật màn hình chính
  }

  // Hàm kiểm tra role của người dùng
  Future<void> _checkUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String? email = user.email;

      try {
        // Lấy thông tin người dùng từ Firestore
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          Map<String, dynamic> userData =
              snapshot.docs.first.data() as Map<String, dynamic>;
          String role = userData['role'];

          // Điều hướng dựa trên role
          if (role == 'user') {
            setState(() {
              _homeScreen = Dashboard();
            });
          } else if (role == 'admin') {
            setState(() {
              _homeScreen = AdminScreen();
            });
          } else {
            setState(() {
              _homeScreen = Dashboard();
            });
          }
        } else {
          setState(() {
            _homeScreen = Dashboard();
          });
        }
      } catch (e) {
        setState(() {
          _homeScreen = _buildErrorScreen('Đã xảy ra lỗi: $e');
        });
      }
    } else {
      setState(() {
        _homeScreen = Dashboard();
      });
    }
  }

  // Hàm tạo màn hình lỗi
  Widget _buildErrorScreen(String errorMessage) {
    return Scaffold(
      body: Center(
        child: Text(
          errorMessage,
          style: const TextStyle(color: Colors.red, fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Hàm xử lý khi người dùng nhấp vào thông báo
  void _handleNotificationClick(RemoteMessage message) {
    final screen = message.data['screen'];
    if (screen == 'NotificationListScreen') {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => NotificationListScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _homeScreen ??
          const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ), // Hiển thị loading khi đang xử lý
      debugShowCheckedModeBanner: false,
    );
  }
}
