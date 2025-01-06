// lib/services/user_infor_myaccount_service.dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserInforMyAccountService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: user!.email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          return querySnapshot.docs.first.data() as Map<String, dynamic>?;
        } else {
          print("No user found with this email.");
          return null;
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
    return null;
  }

  Future<void> saveUserData(Map<String, dynamic> updatedData) async {
    try {
      final email = _auth.currentUser?.email;
      if (email != null) {
        final url = 'http://10.0.2.2:3000/api/appuser/$email';

        final response = await http.patch(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: json.encode(updatedData),
        );

        if (response.statusCode == 200) {
          print('User data updated successfully!');
        } else {
          print('Failed to update user data: ${response.body}');
        }
      }
    } catch (e) {
      print('Error sending request: $e');
    }
  }

  Future<String?> uploadAvatar() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final email = _auth.currentUser?.email;
        if (email == null) {
          print("No email found.");
          return null;
        }

        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          print("No user found with this email.");
          return null;
        }

        String userId = querySnapshot.docs.first.id;

        final storageRef =
            FirebaseStorage.instance.ref().child('avatars/$userId');
        await storageRef.putFile(File(pickedFile.path));

        final downloadUrl = await storageRef.getDownloadURL();
        return downloadUrl;
      }
    } catch (e) {
      print('Error uploading avatar: $e');
    }
    return null;
  }
}
