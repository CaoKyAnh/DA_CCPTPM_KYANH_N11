import 'package:final_project_rent_moto_fe/screens/dashboard.dart';
import 'package:final_project_rent_moto_fe/screens/notification/notificatio_list_by_email_screen.dart';
import 'package:final_project_rent_moto_fe/screens/notification/notification_list_by_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  _MotorbikeBookingNoticeScreenState createState() =>
      _MotorbikeBookingNoticeScreenState();
}

class _MotorbikeBookingNoticeScreenState extends State<NotificationListScreen> {
  int selectedIndex = 0; // Trạng thái tab được chọn

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thông báo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Dashboard()),
            );
          },
        ),
        backgroundColor: const Color(0xFFF49C21),
        elevation: 1,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tab Selection Bar
          Container(
            color: Colors.grey[100], // Màu nền của thanh tab
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTabItem(
                  index: 0,
                  label: 'Yêu cầu đặt xe',
                  icon: Icons.person,
                ),
                const SizedBox(width: 60),
                _buildTabItem(
                  index: 1,
                  label: 'Yêu cầu bạn gửi',
                  icon: Icons.directions_car,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: selectedIndex == 0
                ? _buildNotificationByUserContent()
                : _buildChauffeuredCarsContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(
      {required int index, required String label, required IconData icon}) {
    final bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.green : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          // Thanh gạch chân động
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: isSelected ? 150 : 0,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationByUserContent() {
    return NotificationListByUser(
      email: FirebaseAuth.instance.currentUser?.email ?? '',
    );
  }

  Widget _buildChauffeuredCarsContent() {
    return NotificatioListByEmailScreen(
      email: FirebaseAuth.instance.currentUser?.email ?? '',
    );
  }
}
