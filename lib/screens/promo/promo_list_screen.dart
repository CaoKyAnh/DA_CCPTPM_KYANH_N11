import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'promo_add_screen.dart';
import 'promo_update_screen.dart'; // Import the new PromoUpdateScreen

class PromoListScreen extends StatefulWidget {
  const PromoListScreen({super.key});

  @override
  State<PromoListScreen> createState() => _PromoListScreenState();
}

class _PromoListScreenState extends State<PromoListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<Map<String, dynamic>>> _promosFuture;

  @override
  void initState() {
    super.initState();
    _promosFuture = _fetchPromos();
  }

  // Fetch promotions from Firestore
  Future<List<Map<String, dynamic>>> _fetchPromos() async {
    try {
      final snapshot = await _firestore.collection('promotions').get();
      return snapshot.docs.map((doc) {
        // Add the document ID to each promo data
        var promoData = doc.data() as Map<String, dynamic>;
        promoData['id'] = doc.id; // Adding the document ID
        return promoData;
      }).toList();
    } catch (error) {
      print("Error fetching promotions: $error");
      return [];
    }
  }

  // Refresh the promo list after adding or updating a promo
  void _refreshPromoList() {
    setState(() {
      _promosFuture = _fetchPromos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Khuyến Mãi',
            style: TextStyle(color: Colors.blue)),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // Navigate to PromoAddScreen and refresh the list after returning
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PromoAddScreen()),
              );
              _refreshPromoList(); // Refresh the promo list after adding
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _promosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('Không có khuyến mãi nào.'));
                  }

                  final promos = snapshot.data!;
                  return ListView.builder(
                    itemCount: promos.length,
                    itemBuilder: (ctx, index) {
                      final promo = promos[index];
                      final DateTime startDate =
                          DateTime.parse(promo['startDate']);
                      final DateTime endDate = DateTime.parse(promo['endDate']);
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          leading: promo['imageUrl'] != null
                              ? Image.network(
                                  promo['imageUrl'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.image),
                                )
                              : const Icon(Icons.image, size: 50),
                          title: Text(
                            promo['name'],
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Mã: ${promo['code']}',
                                  style: const TextStyle(fontSize: 14)),
                              Text('Giảm giá: ${promo['discount']}%',
                                  style: const TextStyle(fontSize: 14)),
                              Text(
                                'Ngày bắt đầu: ${DateFormat('dd/MM/yyyy').format(startDate)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Ngày kết thúc: ${DateFormat('dd/MM/yyyy').format(endDate)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PromoUpdateScreen(
                                  documentId: promo[
                                      'id'], // Pass the document ID to PromoUpdateScreen
                                ),
                              ),
                            ).then((_) {
                              // Refresh the list after returning from the update screen
                              _refreshPromoList();
                            }),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
