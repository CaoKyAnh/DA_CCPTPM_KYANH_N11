import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:final_project_rent_moto_fe/screens/history_rent/my_trip_screen.dart';
import 'package:final_project_rent_moto_fe/screens/home/rent_home/rent_home_screen.dart';
import 'package:final_project_rent_moto_fe/screens/users/user_infor_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  final int initialIndex;

  const Dashboard({super.key, this.initialIndex = 0}); // Mặc định là Home

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late int _selectedIndex;
  User? currentUser; // Lưu thông tin người dùng hiện tại

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // Lấy chỉ số từ tham số
  }

  final List<Widget> _screens = [
    const RentHomeScreen(),
    const MyTripScreen(),
    const UserInforScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: const Color(0xFFF49C21),
        color: const Color(0xFFF49C21),
        animationDuration: const Duration(milliseconds: 300),
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.motorcycle_outlined, size: 30, color: Colors.white),
          Icon(Icons.account_box_sharp, size: 30, color: Colors.white),
        ],
        index: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
