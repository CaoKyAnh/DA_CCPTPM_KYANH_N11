// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserInforForm extends StatefulWidget {
  const UserInforForm({super.key});

  @override
  State<UserInforForm> createState() => _UserInforFormState();
}

class _UserInforFormState extends State<UserInforForm>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AnimationController _controller;
  User? user;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      user = _auth.currentUser;
      if (user != null) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: user!.email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            userData = querySnapshot.docs.first.data() as Map<String, dynamic>?;
          });
        } else {
          print("Không tìm thấy người dùng với email này.");
        }
      }
    } catch (e) {
      print("Lỗi khi tải dữ liệu người dùng: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: const Color.fromARGB(255, 244, 156, 33),
      //   title: const Center(
      //     child: Text(
      //       'User Profile',
      //       style: TextStyle(color: Colors.black),
      //     ),
      //   ),
      // ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    userData?['information']?['avatar'] != null
                        ? CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(
                              userData!['information']!['avatar'],
                            ),
                          )
                        : const CircleAvatar(
                            radius: 50,
                            child: Icon(Icons.person,
                                size:
                                    50), // Hiển thị biểu tượng người khi không có ảnh
                          ),
                    Text(
                      userData?['email'] ?? 'No Email',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      userData?['information']?['name'] ?? 'No Name',
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Ngày sinh: ${userData?['information']?['dayOfBirth'] ?? 'N/A'}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Số điện thoại: ${userData?['phoneNumber'] ?? 'N/A'}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Giấy phép lái xe: ${userData?['information']?['gplx'] ?? 'N/A'}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
