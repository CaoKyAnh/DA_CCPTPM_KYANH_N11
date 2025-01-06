// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_rent_moto_fe/screens/favorite_list/list_favorite_by_user.dart';
import 'package:final_project_rent_moto_fe/screens/notification/notification_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RentHomeInforUser extends StatefulWidget {
  const RentHomeInforUser({super.key});

  @override
  State<RentHomeInforUser> createState() => _RentHomeInforUserState();
}

class _RentHomeInforUserState extends State<RentHomeInforUser> {
  String? userName;
  String? phoneNumber;
  String? avatarUrl;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLogin = prefs.getBool('isLogin') ?? false;

    if (isLogin) {
      fetchDataUser();
    }
  }

  Future<void> fetchDataUser() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userEmail = currentUser.email;

        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: userEmail)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          final userData = userSnapshot.docs.first.data();
          setState(() {
            userName = userData['information']['name'] ?? 'Unknown';
            phoneNumber = userData['phoneNumber'] ?? 'No phone';
            avatarUrl = userData['information']['avatar'];
          });
        }
      }
    } catch (e) {
      print("Lỗi khi lấy thông tin người dùng: $e");
    }
  }

  Stream<int> fetchBookingCount() {
    final String currentUserEmail =
        FirebaseAuth.instance.currentUser?.email ?? '';

    // First, get the email from the motorcycles collection using the number plate
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('isAccept',
            isEqualTo: false) // Filter for bookings where 'isAccept' is false
        .snapshots()
        .asyncMap((bookingSnapshot) async {
      // Create a list to hold the count of accepted bookings for the user
      int count = 0;

      // For each booking, we need to query the motorcycles collection
      for (var doc in bookingSnapshot.docs) {
        final numberPlate =
            doc['numberPlate']; // Get the number plate from the booking

        // Query the motorcycles collection for the matching number plate
        final motorcycleSnapshot = await FirebaseFirestore.instance
            .collection('motorcycles')
            .where('numberPlate',
                isEqualTo: numberPlate) // Filter by number plate
            .limit(1) // Only get one motorcycle document
            .get();

        if (motorcycleSnapshot.docs.isNotEmpty) {
          // If a motorcycle is found, retrieve its email
          final motorcycleEmail = motorcycleSnapshot.docs.first['email'];

          // Now check if the email matches the current user's email
          if (motorcycleEmail == currentUserEmail) {
            // If the email matches, increment the count
            count++;
          }
        }
      }

      return count; // Return the final count after processing all bookings
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 15,
      top: 30,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orangeAccent.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        width: MediaQuery.of(context).size.width - 30,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  maxRadius: 25,
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                  child: avatarUrl == null ? const Icon(Icons.person) : null,
                ),
                const SizedBox(width: 15),
                userName != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName ?? "Loading...",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.red,
                            ),
                          ),
                          Text(
                            phoneNumber ?? "Loading...",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        "Chào mừng!",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
              ],
            ),
            if (userName != null)
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ListFavoriteByUser(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.favorite,
                      size: 18,
                      color: Colors.red,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 12,
                    color: Colors.red,
                  ),
                  StreamBuilder<int>(
                    stream: fetchBookingCount(),
                    builder: (context, snapshot) {
                      // Check the state of the stream
                      final int bookingCount = snapshot.data ??
                          0; // Get the number of unaccepted bookings

                      return IconButton(
                        onPressed: () async {
                          // When the icon is clicked, navigate to NotificationListByUser
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              // builder: (context) => NotificationListByUser(
                              //   email:
                              //       FirebaseAuth.instance.currentUser?.email ??
                              //           '',
                              // ),
                              builder: (context) => NotificationListScreen(),
                            ),
                          );
                        },
                        icon: Stack(
                          children: [
                            const Icon(
                              Icons.notifications,
                              color: Colors.blueGrey,
                            ),
                            // Show a badge if there are any unaccepted bookings
                            if (bookingCount > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 10,
                                    minHeight: 10,
                                  ),
                                  child: Text(
                                    '$bookingCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 7,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }
}
