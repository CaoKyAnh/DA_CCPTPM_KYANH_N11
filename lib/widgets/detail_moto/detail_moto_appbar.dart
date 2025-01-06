// ignore_for_file: unused_element

import 'package:final_project_rent_moto_fe/screens/dashboard.dart';
import 'package:final_project_rent_moto_fe/services/favorite_list/add_favoritelist_service.dart';
import 'package:final_project_rent_moto_fe/services/favorite_list/delete_favoritelist_service.dart';
import 'package:final_project_rent_moto_fe/services/favorite_list/get_favoritelist_service.dart';
import 'package:final_project_rent_moto_fe/widgets/notification/error_notification.dart';
import 'package:final_project_rent_moto_fe/widgets/notification/success_notification.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class DetailMotoAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Map<String, dynamic>
      motorcycle; // The motorcycle object passed from previous screen

  const DetailMotoAppBar({super.key, required this.motorcycle});

  @override
  _DetailMotoAppBarState createState() => _DetailMotoAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _DetailMotoAppBarState extends State<DetailMotoAppBar> {
  bool isFavorite = false; // Track if the motorcycle is a favorite
  late String motorcycleId;
  late String userEmail;

  @override
  void initState() {
    super.initState();
    motorcycleId = widget.motorcycle['id'] ?? 'No motorcycle ID available';
    _loadUserFavoriteState(); // Check if the motorcycle is a favorite for the logged-in user
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      ErrorNotification(text: message).buildSnackBar(),
    );
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SuccessNotification(text: message).buildSnackBar(),
    );
  }

  // Load the user's favorite state from the backend or local storage
  Future<void> _loadUserFavoriteState() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        userEmail = currentUser.email ?? 'No email available';
      });

      try {
        // Get the list of favorite motorcycle IDs for the current user
        List<String> favoriteMotorcycles = await getFavoriteList(
            userEmail); // Replace with your service method
        // Check if the current motorcycle ID is in the user's favorite list
        if (favoriteMotorcycles.contains(motorcycleId)) {
          setState(() {
            isFavorite = true;
          });
        }
      } catch (e) {
        print("Failed to load favorite state: $e");
      }
    }
  }

  Future<void> toggleFavorite() async {
    // Get the current user's email
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const Dashboard(initialIndex: 2), // Chỉ số UserInforScreen
          ),
        );
      }
      return;
    }
    final String email = currentUser?.email ?? 'No email available';
    final String motorcycleId =
        widget.motorcycle['id'] ?? 'No motorcycle ID available';
    // Show loading indicator or any visual feedback
    setState(() {
      isFavorite = !isFavorite; // Toggle the favorite state locally
    });

    try {
      if (isFavorite) {
        await addFavoriteList(email, [motorcycleId]);
        if (mounted) {
          _showSuccessMessage(context, 'Đã thêm xe vào danh sách yêu thích!');
        }
      } else {
        await deleteFavoriteListService(email, motorcycleId);
        if (mounted) {
          _showErrorMessage(context, 'Đã xóa xe khỏi danh sách yêu thích!');
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          isFavorite = !isFavorite; // Revert the local favorite state
        });
        print("Failed to update favorite list: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update favorite list: $error")),
        );
      }
    }
  }

  void _onBackButtonPressed() {
    Navigator.pop(context, {
      'motorcycleId': motorcycleId,
      'isFavorite': isFavorite,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 255, 173, 21),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: _onBackButtonPressed, // Use the custom back button handler
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Text(
                "${widget.motorcycle['numberPlate'] ?? 'Unknown'}",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: isFavorite
                  ? Colors.red
                  : Colors.white, // Change color based on state
            ),
            onPressed: toggleFavorite,
            // Handle the icon press
          ),
        ],
      ),
    );
  }
}
