// ignore_for_file: avoid_print

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:final_project_rent_moto_fe/widgets/modals/form_day_month_year.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserInforMyaccount extends StatefulWidget {
  const UserInforMyaccount({super.key});

  @override
  State<UserInforMyaccount> createState() => _UserInforMyaccountState();
}

class _UserInforMyaccountState extends State<UserInforMyaccount> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  User? user;
  Map<String, dynamic>? userData;
  bool isEditing = false;
  bool isUploading = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController dayOfBirthController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController gplxController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
            _initializeControllers();
          });
        } else {
          print("Không tìm thấy người dùng với email này.");
        }
      }
    } catch (e) {
      print("Lỗi khi tải dữ liệu người dùng: $e");
    }
  }

  void _initializeControllers() {
    nameController.text = userData?['information']?['name'] ?? '';
    dayOfBirthController.text = userData?['information']?['dayOfBirth'] ?? '';
    phoneNumberController.text = userData?['phoneNumber'] ?? '';
    gplxController.text = userData?['information']?['gplx'] ?? '';
  }

  Future<void> _showDatePicker() async {
    String initialDate = dayOfBirthController.text;

    showDialog(
      context: context,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: FormSelectDayMonthYear(
            initialDate: initialDate,
            onDateSelected: (date) {
              setState(() {
                dayOfBirthController.text = date;
              });
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  Future<void> saveUserData() async {
    // Tên người dùng kiểm tra
    if (nameController.text.isEmpty || nameController.text.length < 2) {
      _showErrorDialog('Tên phải có ít nhất 2 ký tự.');
      return;
    }

    // Số điện thoại kiểm tra
    if (phoneNumberController.text.isEmpty ||
        phoneNumberController.text.length != 10) {
      _showErrorDialog('Số điện thoại phải có đúng 10 chữ số.');
      return;
    }

    // GPLX kiểm tra
    if (gplxController.text.isEmpty) {
      _showErrorDialog('Giấy phép lái xe không được để trống.');
      return;
    }
    if (!RegExp(r'^\d{12}$').hasMatch(gplxController.text)) {
      _showErrorDialog('Giấy phép lái xe phải có đúng 12 chữ số.');
      return;
    }

    // Ngày sinh kiểm tra
    if (dayOfBirthController.text.isEmpty) {
      _showErrorDialog('Ngày sinh không thể để trống.');
      return;
    }

    try {
      final email = user?.email;
      final url = 'http://10.0.2.2:3000/api/appuser/$email';

      final updatedData = {
        "information": {
          "name": nameController.text,
          "dayOfBirth": dayOfBirthController.text,
          "gplx": gplxController.text,
        },
        "phoneNumber": phoneNumberController.text,
      };

      final response = await http.patch(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        print('Dữ liệu người dùng đã được cập nhật thành công!');

        // Cập nhật lại dữ liệu người dùng mới sau khi thay đổi
        setState(() {
          userData?['information']?['name'] = nameController.text;
          userData?['information']?['dayOfBirth'] = dayOfBirthController.text;
          userData?['phoneNumber'] = phoneNumberController.text;
          isEditing = false; // Tắt chế độ chỉnh sửa
        });

        // Trả về tên mới (cập nhật) nếu không có thay đổi avatar
        Navigator.pop(context, {
          'name': nameController.text, // Tên người dùng mới
        });
      } else {
        print('Cập nhật dữ liệu người dùng không thành công: ${response.body}');
      }
    } catch (e) {
      print('Lỗi khi gửi yêu cầu: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Hoàn Tất'),
          ),
        ],
      ),
    );
  }

  Future<void> _changeAvatar() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          isUploading = true;
        });

        final email = user?.email;
        if (email == null) {
          print("Không tìm thấy email.");
          setState(() {
            isUploading = false;
          });
          return;
        }

        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          setState(() {
            isUploading = false;
          });
          print("Không tìm thấy người dùng với email này.");
          return;
        }

        String userId = querySnapshot.docs.first.id;
        final storageRef =
            FirebaseStorage.instance.ref().child('avatars/$userId');
        await storageRef.putFile(File(pickedFile.path));

        final downloadUrl = await storageRef.getDownloadURL();

        // Cập nhật avatar URL trong Firestore
        await _firestore
            .collection('users')
            .doc(userId)
            .update({'information.avatar': downloadUrl});

        setState(() {
          userData?['information']?['avatar'] = downloadUrl;
          isUploading = false;
        });

        // Trả về avatar và tên mới
        Navigator.pop(context, {
          'avatar': downloadUrl, // avatar mới
          'name': nameController.text, // tên người dùng mới
        });

        print('Cập nhật avatar thành công!');
      }
    } catch (e) {
      setState(() {
        isUploading = false;
      });
      print('Lỗi khi cập nhật avatar: $e');
    }
  }

  Widget _buildInfoField(
      String label, String value, TextEditingController controller,
      {bool isDateField = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          isEditing
              ? isDateField
                  ? GestureDetector(
                      onTap: _showDatePicker,
                      child: Container(
                        width: screenWidth - 20,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          controller.text.isNotEmpty
                              ? controller.text
                              : 'Chọn ngày sinh',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  : TextField(
                      controller: controller,
                      keyboardType: _getKeyboardType(label),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Nhập $label',
                      ),
                      style: const TextStyle(fontSize: 16),
                    )
              : Container(
                  width: screenWidth - 20,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    value.isNotEmpty ? value : 'Chưa xác thực',
                    style: TextStyle(
                      color: value.isEmpty ? Colors.red : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  TextInputType _getKeyboardType(String label) {
    if (label == 'phoneNumber') {
      return TextInputType.phone;
    } else if (label == 'license') {
      return TextInputType.number;
    } else {
      return TextInputType.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Tài khoản của tôi'),
        backgroundColor: const Color(0xFFF49C21),
        actions: isEditing
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      isEditing = true;
                    });
                  },
                ),
              ],
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              // Thêm phần này
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          userData?['information']?['avatar'] != null
                              ? CircleAvatar(
                                  radius: 50,
                                  backgroundImage: NetworkImage(
                                      userData!['information']!['avatar']),
                                )
                              : const CircleAvatar(
                                  radius: 50,
                                  child: Icon(Icons.person, size: 50),
                                ),
                          if (isEditing)
                            InkWell(
                              onTap: isUploading ? null : _changeAvatar,
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                padding: const EdgeInsets.all(4.0),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                            ),
                          if (isUploading)
                            const Positioned.fill(
                              child: CircularProgressIndicator(),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userData?['email'] ?? 'No Email',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        children: [
                          _buildInfoField(
                              'Tài khoản của tôi',
                              userData?['information']?['name'] ?? '',
                              nameController),
                          _buildInfoField(
                              'Ngày sinh',
                              userData?['information']?['dayOfBirth'] ?? '',
                              dayOfBirthController,
                              isDateField: true),
                          _buildInfoField(
                              'Số điện thoại',
                              userData?['phoneNumber'] ?? '',
                              phoneNumberController),
                          _buildInfoField(
                              'Giấy phép lái xe',
                              userData?['information']?['gplx'] ?? '',
                              gplxController),
                        ],
                      ),
                    ),
                    if (isEditing)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isEditing = false;
                                _initializeControllers();
                              });
                            },
                            child: const Text("Thoát"),
                          ),
                          ElevatedButton(
                            onPressed: saveUserData,
                            child: const Text("Lưu"),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
