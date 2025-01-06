// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ApplyPromoService {
  // Hàm lấy chi tiết mã khuyến mãi từ Firestore
  Future<Map<String, dynamic>?> fetchPromoDetails(String promoCode) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('promotions')
          .where('code', isEqualTo: promoCode)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print('Lỗi khi lấy mã khuyến mãi: $e');
      return null;
    }
  }

  // Hàm áp dụng mã khuyến mãi
  Future<int> applyPromo({
    required String promoCode,
    required int totalAmount,
    required Map<String, dynamic> promoDetails,
  }) async {
    if (promoCode != promoDetails['code']) {
      throw Exception('Mã khuyến mãi không hợp lệ');
    }

    DateTime startDate = DateTime.parse(promoDetails['startDate']);
    DateTime endDate = DateTime.parse(promoDetails['endDate']);
    DateTime today = DateTime.now();

    if (today.isBefore(startDate) || today.isAfter(endDate)) {
      throw Exception('Khuyến mãi này đã hết hạn hoặc chưa được kích hoạt');
    }

    if (promoDetails['isHide'] == true) {
      throw Exception('Khuyến mãi này hiện không khả dụng');
    }

    int discount = promoDetails['discount'];
    int discountedAmount =
        (totalAmount * (100 - discount) ~/ 100); // Sử dụng tổng tiền ban đầu

    return discountedAmount;
  }

  // Hiển thị thông báo SnackBar
  void showSnackbar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> applyPromoHandler(
      BuildContext context, String promoCode, int totalAmount) async {
    try {
      // Gọi hàm `fetchPromoDetails`
      Map<String, dynamic>? promoDetails = await fetchPromoDetails(promoCode);

      if (promoDetails == null) {
        showSnackbar(context, 'Mã khuyến mãi không tồn tại', isError: true);
        return;
      }

      // Gọi hàm `applyPromo`
      int discountedAmount = await applyPromo(
        promoCode: promoCode,
        totalAmount: totalAmount,
        promoDetails: promoDetails,
      );

      showSnackbar(
        context,
        'Áp dụng thành công!',
        isError: false,
      );
    } catch (e) {
      // Hiển thị thông báo lỗi
      showSnackbar(context, e.toString(), isError: true);
    }
  }
}
