// ignore_for_file: avoid_print

import 'package:final_project_rent_moto_fe/screens/MotorCycle/motorcycle_list_by_user.dart';
import 'package:final_project_rent_moto_fe/screens/auth/login/login_screen.dart';
import 'package:final_project_rent_moto_fe/screens/dashboard.dart';
import 'package:final_project_rent_moto_fe/services/fcm/fcm_service.dart';
import 'package:final_project_rent_moto_fe/widgets/users/user_infor_change_password.dart';
import 'package:final_project_rent_moto_fe/screens/favorite_list/list_favorite_by_user.dart';
import 'package:final_project_rent_moto_fe/widgets/users/user_infor_myaccount_form.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInforBody extends StatefulWidget {
  const UserInforBody({super.key});

  @override
  State<UserInforBody> createState() => _UserInforBodyState();
}

class _UserInforBodyState extends State<UserInforBody> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userName;
  String? avatarUrl;
  String? email;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _fetchUserNameAndAvatar();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLogin') ?? false;
    });
  }

  Future<void> _fetchUserNameAndAvatar() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final userData = querySnapshot.docs.first.data();
          setState(() {
            userName = userData['information']?['name'];
            avatarUrl = userData['information']?['avatar'];
            email = user.email;
          });
        } else {
          print("No user found with this email.");
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return isLoggedIn
        ? SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  height: screenHeight * 0.27,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/image_background1.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    color: Colors.black.withOpacity(0.2),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 5, right: 5, bottom: 100),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.2),
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: avatarUrl != null
                            ? NetworkImage(avatarUrl!)
                            : AssetImage('assets/avatar.png') as ImageProvider,
                      ),
                      SizedBox(height: 16),
                      Text(
                        userName ?? 'User Name',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildMenuItem(
                                  Icons.person, 'Tài khoản của tôi', context),
                              Divider(indent: 30.0, endIndent: 30.0),
                              _buildMenuItem(Icons.car_rental,
                                  'Danh sách xe của bạn', context),
                              Divider(indent: 30.0, endIndent: 30.0),
                              _buildMenuItem(Icons.favorite,
                                  'Danh sách xe yêu thích', context),
                              Divider(indent: 30.0, endIndent: 30.0),
                              _buildMenuItem(Icons.location_on,
                                  'Địa chỉ của tôi', context),
                              Divider(indent: 30.0, endIndent: 30.0),
                              _buildMenuItem(Icons.card_membership,
                                  'Giấy phép lái xe', context),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildMenuItem(
                                  Icons.lock, 'Đổi mật khẩu', context),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await FCMService().removeFcmTokenOnSignOut();

                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('isLogin', false);
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Dashboard()),
                          );
                        },
                        icon: Icon(Icons.logout, color: Colors.red),
                        label: Text(
                          'Đăng xuất',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          side: BorderSide(color: Colors.red),
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                )
              ],
            ),
          )
        : LoginScreen();
  }

  Widget _buildMenuItem(IconData icon, String title, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16.0),
      onTap: () async {
        if (title == 'Tài khoản của tôi') {
          final updatedData = await Navigator.push<Map<String, String>>(
            context,
            MaterialPageRoute(
              builder: (context) => const UserInforMyaccount(),
            ),
          );

          if (updatedData != null) {
            setState(() {
              avatarUrl = updatedData['avatar'] ?? avatarUrl;
              userName = updatedData['name'] ?? userName;
            });
          }
        } else if (title == 'Danh sách xe của bạn') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MotorcycleListByUser()),
          );
        } else if (title == 'Đổi mật khẩu') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserInforChangePassword(
                email: email!,
              ),
            ),
          );
        } else if (title == 'Danh sách xe yêu thích') {
          // Navigate to the list of favorite motorcycles
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ListFavoriteByUser()),
          );
        }
      },
    );
  }
}
