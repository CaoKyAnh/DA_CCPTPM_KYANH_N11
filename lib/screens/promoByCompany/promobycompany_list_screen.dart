import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'promobycompany_edit_screen.dart';
import 'promobycompay_add_screen.dart';

class PromobycompanyListScreen extends StatefulWidget {
  const PromobycompanyListScreen({super.key});

  @override
  State<PromobycompanyListScreen> createState() =>
      _PromobycompanyListScreenState();
}

class _PromobycompanyListScreenState extends State<PromobycompanyListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _fetchPromos() async {
    try {
      final snapshot = await _firestore.collection('promotionsByCompany').get();
      return snapshot.docs.map((doc) {
        final promoData = doc.data() as Map<String, dynamic>;
        promoData['id'] = doc.id;
        return promoData;
      }).toList()
        ..sort((a, b) => DateTime.parse(a['startDate'])
            .compareTo(DateTime.parse(b['startDate'])));
    } catch (error) {
      throw 'Error fetching promotions: $error';
    }
  }

  void _refreshPromoList() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Khuyến Mãi Theo Loại Xe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PromobycompayAddScreen()),
              );
              _refreshPromoList();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchPromos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có khuyến mãi nào.'));
          }

          final promos = snapshot.data!;
          return ListView.builder(
            itemCount: promos.length,
            itemBuilder: (ctx, index) {
              final promo = promos[index];
              final startDate = DateTime.parse(promo['startDate']);
              final endDate = DateTime.parse(promo['endDate']);
              return Card(
                child: ListTile(
                  title: Text(promo['promoName']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Loại xe: ${promo['companyMoto']['name']}'),
                      Text('Giảm giá: ${promo['percentage']}%'),
                      Text(
                          'Ngày bắt đầu: ${DateFormat('dd-MM-yyyy').format(startDate)}'),
                      Text(
                          'Ngày kết thúc: ${DateFormat('dd-MM-yyyy').format(endDate)}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      // Kiểm tra nếu dữ liệu đầy đủ
                      if (promo['promoName'] == null ||
                          promo['companyMoto'] == null ||
                          promo['startDate'] == null ||
                          promo['endDate'] == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Dữ liệu khuyến mãi không đầy đủ.')),
                        );
                        return;
                      }

                      // Điều hướng nếu dữ liệu hợp lệ
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PromobycompanyEditScreen(
                            promoId: promo['id'],
                            promoData: promo,
                          ),
                        ),
                      );

                      // Làm mới danh sách sau khi chỉnh sửa
                      _refreshPromoList();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
