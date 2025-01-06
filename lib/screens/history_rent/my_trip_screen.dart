// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_rent_moto_fe/screens/dashboard.dart';
import 'package:final_project_rent_moto_fe/screens/history_rent/history_trip_screen.dart';
import 'package:final_project_rent_moto_fe/services/invoice/invoice_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'my_trip_nologin.dart'; // Import your no-login screen

class MyTripScreen extends StatefulWidget {
  const MyTripScreen({super.key});

  @override
  State<MyTripScreen> createState() => _MyTripScreenState();
}

class _MyTripScreenState extends State<MyTripScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isLoggedIn = false;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final String email = FirebaseAuth.instance.currentUser?.email ?? '';
  final InvoiceService invoiceService = InvoiceService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLogin') ?? false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String?> _getMotorcycleImageUrl(String numberPlate) async {
    try {
      // Query the 'motorcycles' collection based on the numberPlate
      final snapshot = await FirebaseFirestore.instance
          .collection('motorcycles')
          .where('numberPlate', isEqualTo: numberPlate)
          .get();

      // If there's a matching document, return the first image URL
      if (snapshot.docs.isNotEmpty) {
        var motorcycleData = snapshot.docs.first.data();
        // Access images from the nested informationMoto field
        var images = List<String>.from(
            motorcycleData['informationMoto']['images'] ?? []);
        if (images.isNotEmpty) {
          return images[0]; // Return the first image URL
        }
      }
    } catch (e) {
      print('Error fetching motorcycle image: $e');
    }
    return null; // Return null if no image found
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return const MyTripNologin(); // Show if not logged in
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF49C21),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Dashboard(),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Chuyến xe của tôi',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.history, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryTripScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: invoiceService.getInvoicesByEmail(email),
        builder: (context, snapshot) {
          // Check the state of the Future
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No trips found'));
          } else {
            // Lọc danh sách để chỉ hiển thị các chuyến đi đã hoàn thành
            final now = DateTime.now();
            final completedTrips = snapshot.data!
                .where((invoice) =>
                    DateTime.parse(invoice['returnDate']).isAfter(now))
                .toList();

            if (completedTrips.isEmpty) {
              return const Center(
                  child: Text('Không có chuyến đi đã hoàn thành.'));
            }

            return ListView.builder(
              itemCount: completedTrips.length,
              itemBuilder: (context, index) {
                final invoice = completedTrips[index];
                String numberPlate = invoice['numberPlate'];

                return FutureBuilder<String?>(
                  future: _getMotorcycleImageUrl(numberPlate),
                  builder: (context, imageSnapshot) {
                    if (imageSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (imageSnapshot.hasError) {
                      return Center(
                          child: Text(
                              'Error loading image: ${imageSnapshot.error}'));
                    } else if (imageSnapshot.hasData &&
                        imageSnapshot.data != null) {
                      String imageUrl = imageSnapshot.data!;
                      DateTime returnDate =
                          DateTime.parse(invoice['returnDate']);

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 100,
                                child: Image.network(
                                  imageUrl, // Display the fetched image URL
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Biển số: ${invoice['numberPlate']}'),
                                    Text(
                                      'Ngày trả: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(
                                        returnDate.toLocal(),
                                      )}',
                                    ),
                                  ],
                                ),
                              ),
                              const Text(
                                'Đang hoàn thành ', // Thay thế nút bằng Text
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return const Center(child: Text('No image found'));
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
