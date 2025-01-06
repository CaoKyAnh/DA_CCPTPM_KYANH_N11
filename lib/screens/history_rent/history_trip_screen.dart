import 'package:flutter/material.dart';
import 'package:final_project_rent_moto_fe/screens/dashboard.dart';
import 'package:final_project_rent_moto_fe/screens/review/review_screen.dart';
import 'package:final_project_rent_moto_fe/services/invoice/invoice_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryTripScreen extends StatefulWidget {
  const HistoryTripScreen({super.key});

  @override
  State<HistoryTripScreen> createState() => _HistoryTripScreenState();
}

class _HistoryTripScreenState extends State<HistoryTripScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isLoggedIn = false;
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

  Future<String?> _getMotorcycleImageUrl(String numberPlate) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('motorcycles')
          .where('numberPlate', isEqualTo: numberPlate)
          .get();
      if (snapshot.docs.isNotEmpty) {
        var images = List<String>.from(
            snapshot.docs.first.data()['informationMoto']['images'] ?? []);
        return images.isNotEmpty ? images[0] : null;
      }
    } catch (e) {
      debugPrint('Error fetching motorcycle image: $e');
    }
    return null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return const Center(
        child: Text('Vui lòng đăng nhập để xem lịch sử chuyến đi.'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 244, 156, 33),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Text(
              'Lịch Sử Chuyến Đi',
              style: TextStyle(color: Colors.black),
            ),
            Spacer(),
          ],
        ),
        leading: IconButton(
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
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: invoiceService.getInvoicesByEmail(email),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có lịch sử chuyến đi.'));
          }

          // Lọc danh sách các chuyến đi đã hoàn thành
          final now = DateTime.now();
          final invoices = snapshot.data!
              .where((invoice) =>
                  DateTime.parse(invoice['returnDate']).isBefore(now))
              .toList();

          if (invoices.isEmpty) {
            return const Center(
                child: Text('Không có chuyến đi đã hoàn thành.'));
          }

          return ListView.builder(
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              final returnDate = DateTime.parse(invoice['returnDate']);
              final numberPlate = invoice['numberPlate'];

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
                  }

                  final imageUrl = imageSnapshot.data ?? '';

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image, size: 100),
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Biển số: ${invoice['numberPlate']}'),
                                Text(
                                  'Ngày trả: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(returnDate.toLocal())}',
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReviewScreen(
                                      numberPlate: invoice['numberPlate']),
                                ),
                              );
                            },
                            child: const Text('Đánh giá'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
