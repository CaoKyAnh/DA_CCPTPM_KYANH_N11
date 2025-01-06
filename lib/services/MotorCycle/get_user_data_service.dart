// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  Future<Map<String, dynamic>?> getUserData(String email) async {
    try {
      // Query Firestore collection "users" where the email matches the given email
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        return userSnapshot.docs[0].data() as Map<String, dynamic>;
      } else {
        print("User data not found for email: $email");
        return null;
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  Future<String> getSenderName(String email) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('No user found with email: $email');
    }

    return querySnapshot.docs.first.data()['information']['name'] ??
        'User Name';
  }
}
