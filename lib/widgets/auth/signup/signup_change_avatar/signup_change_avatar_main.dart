// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'dart:io';
import 'package:final_project_rent_moto_fe/services/auth/signup_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SignupChangeAvatarMain extends StatefulWidget {
  final String email;
  const SignupChangeAvatarMain({super.key, required this.email});

  @override
  _SignupChangeAvatarMainState createState() => _SignupChangeAvatarMainState();
}

class _SignupChangeAvatarMainState extends State<SignupChangeAvatarMain> {
  final ImagePicker imagePicker = ImagePicker();
  XFile? selectedImage;
  final _signupService = SignupService();
  // Hàm để tải ảnh lên Firebase Storage
  Future<String?> uploadImageToFirebase(XFile image) async {
    try {
      File file = File(image.path);
      print("Uploading image from path: ${image.path}");

      // Tạo tên file duy nhất bằng timestamp
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref =
          FirebaseStorage.instance.ref().child('avatars/$fileName');

      // Tải lên ảnh
      await ref.putFile(file);

      // Lấy URL tải xuống
      String downloadUrl = await ref.getDownloadURL();
      print("Uploaded image URL: $downloadUrl");

      return downloadUrl;
    } catch (error) {
      print("Error uploading image: $error");
      return null;
    }
  }

  // Hàm để chọn ảnh và tải lên
  Future<void> pickImage() async {
    try {
      final XFile? image =
          await imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          selectedImage = image;
        });

        // Tải ảnh lên Firebase và lấy URL
        String? avatarUrl = await uploadImageToFirebase(image);

        if (avatarUrl != null) {
          // Cập nhật URL ảnh vào Firestore
          await _signupService.updateAvatar(
              email: widget.email, avatarUrl: avatarUrl);
        }
      }
    } catch (error) {
      print("Error picking image: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          maxRadius: 100,
          backgroundImage: selectedImage != null
              ? FileImage(File(selectedImage!.path))
              : null,
          child: selectedImage == null
              ? const Icon(Icons.person,
                  size: 100) // Icon mặc định khi chưa có ảnh
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                width: 0.1,
                color: Colors.black,
              ),
            ),
            child: TextButton(
              onPressed: pickImage, // Gọi hàm pickImage khi nhấn nút
              child: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
