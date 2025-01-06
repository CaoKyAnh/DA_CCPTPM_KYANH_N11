import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_rent_moto_fe/screens/MotorCycle/add_motorcycle_screen.dart';
import 'package:final_project_rent_moto_fe/screens/auth/login/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RentHomeMotoRental extends StatefulWidget {
  const RentHomeMotoRental({super.key});

  @override
  State<RentHomeMotoRental> createState() => _RentHomeMotoRentalState();
}

Future<String?> _checkLicenseIsValid(BuildContext context) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    // If no user is logged in, navigate to the LoginScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
    return null; // Return null because the user is not logged in
  }

  final userEmail = currentUser.email;
  final userSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: userEmail)
      .get();

  if (userSnapshot.docs.isNotEmpty) {
    final userData = userSnapshot.docs.first.data();

    // Check if the 'gplx' field exists, is not empty, and is exactly 12 digits long
    String gplx = userData['information']['gplx'] ?? '';
    if (gplx.isNotEmpty &&
        gplx.length == 12 &&
        RegExp(r'^\d{12}$').hasMatch(gplx)) {
      // If 'gplx' is valid, return the user's role
      return userData['role']; // Return the user's role from Firestore
    } else {
      // If 'gplx' is invalid, show a message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please update your driver\'s license (GPLX).'),
        ),
      );
      return null; // Return null if 'gplx' is invalid
    }
  } else {
    // If no user data is found in Firestore, navigate to LoginScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
    return null; // Return null if no user data is found
  }
}

class _RentHomeMotoRentalState extends State<RentHomeMotoRental> {
  void _navigateToAddMotorcycleScreen(BuildContext context) async {
    // Check user's 'gplx' validity before navigating
    final userRole = await _checkLicenseIsValid(context);
    if (userRole != null) {
      // If 'gplx' is valid, navigate to AddMotorcycleScreen
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                AddMotorcycleScreen()), // Replace with your actual screen
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      // padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/moto_rental.jpg', // Replace with your image path
                  fit: BoxFit.cover,
                  height: 180,
                  width: double.infinity,
                ),
              ),
            ],
          ),
          const Positioned(
            child: Padding(
              padding: EdgeInsets.only(top: 10, left: 20),
              child: Text(
                "Bạn có muốn đăng xe lên cho thuê?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                _navigateToAddMotorcycleScreen(context);
              },
              child: const Text(
                "Đăng xe lên cho thuê",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
