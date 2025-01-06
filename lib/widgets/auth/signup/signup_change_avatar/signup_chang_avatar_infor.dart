// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SignupChangAvatarInfor extends StatefulWidget {
  final String email;
  const SignupChangAvatarInfor({super.key, required this.email});

  @override
  State<SignupChangAvatarInfor> createState() => _SignupChangAvatarInforState();
}

class _SignupChangAvatarInforState extends State<SignupChangAvatarInfor> {
  Map<String, dynamic>? userData; // Dùng để lưu dữ liệu người dùng

  // Hàm fetchDataUser để lấy thông tin người dùng theo email
  Future<void> fetchDataUser() async {
    try {
      // Truy vấn Firebase Firestore với email
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Lấy dữ liệu từ document đầu tiên tìm thấy
        var userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          this.userData = {
            'gplx': userData['information']['gplx'] ?? 'Không có thông tin',
            'name': userData['information']['name'] ?? 'Không có thông tin',
            'phoneNumber': userData['phoneNumber'] ?? 'Không có thông tin',
            'dayOfBirth':
                userData['information']['dayOfBirth'] ?? 'Không có thông tin',
          };
        });
      }
    } catch (error) {
      print('Lỗi khi lấy dữ liệu người dùng: $error');
    }
  }

  // Hàm tạo widget thông tin
  Widget fieldInfoRow(String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Text(
            sub,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    fetchDataUser(); // Gọi hàm fetchDataUser để lấy dữ liệu khi màn hình được mở
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const CircularProgressIndicator(); // Hiển thị khi chưa có dữ liệu
    }

    // Lấy dữ liệu từ userData
    final licenseNumber = userData!['gplx'];
    final fullName = userData!['name'];
    final phoneNumber = userData!['phoneNumber'];
    final dateOfBirth = userData!['dayOfBirth'];

    return Container(
      height: 200,
      width: 350,
      decoration: const BoxDecoration(
        color: Color.fromARGB(77, 196, 198, 198),
      ),
      child: Card(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(162, 255, 255, 255),
                Color.fromARGB(82, 255, 173, 21),
                Color.fromARGB(123, 255, 173, 21),
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 10),
                    height: 100,
                    child: Image.asset("assets/images/logo.png"),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    const Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        "THÔNG TIN CỦA BẠN",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    fieldInfoRow("Họ và tên", fullName),
                    const SizedBox(
                      height: 5,
                    ),
                    fieldInfoRow("Giấp phép lái xe", licenseNumber),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        fieldInfoRow("Số điện thoại", phoneNumber),
                        const SizedBox(
                          width: 30,
                        ),
                        fieldInfoRow("Ngày sinh", dateOfBirth),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
