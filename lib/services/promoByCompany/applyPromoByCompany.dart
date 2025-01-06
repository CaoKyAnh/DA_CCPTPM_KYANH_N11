import 'package:cloud_firestore/cloud_firestore.dart';

class ApplyPromoByCompanyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ApplyPromoByCompanyService();

  Future<double> applyPromotion(String motorcycleId) async {
    try {
      // Lấy dữ liệu xe máy từ Firestore
      DocumentSnapshot motorcycleDoc =
          await _firestore.collection('motorcycles').doc(motorcycleId).get();

      if (!motorcycleDoc.exists) {
        throw Exception("Xe máy không tồn tại");
      }

      Map<String, dynamic> motorcycleData =
          motorcycleDoc.data() as Map<String, dynamic>;
      String motorcycleCompanyName =
          motorcycleData['companyMoto']?['name'] ?? '';

      if (motorcycleCompanyName.isEmpty) {
        throw Exception("Tên hãng xe máy không có sẵn");
      }

      // Lấy giá gốc của xe
      double originalPrice =
          (motorcycleData['informationMoto']?['price'] ?? 0.0).toDouble();

      // Lấy danh sách khuyến mãi của công ty từ Firestore
      QuerySnapshot promoSnapshot = await _firestore
          .collection('promotionsByCompany')
          .where('companyMoto.name', isEqualTo: motorcycleCompanyName)
          .where('isHide', isEqualTo: false) // Khuyến mãi đang hoạt động
          .get();

      if (promoSnapshot.docs.isEmpty) {
        // Không tìm thấy khuyến mãi, trả về giá gốc
        return originalPrice;
      }

      // Tìm khuyến mãi hợp lệ nhất (nếu có nhiều khuyến mãi)
      DocumentSnapshot promoDoc = promoSnapshot.docs.first;
      Map<String, dynamic> promoData = promoDoc.data() as Map<String, dynamic>;

      // Kiểm tra ngày bắt đầu và kết thúc
      DateTime startDate = DateTime.parse(promoData['startDate']);
      DateTime endDate = DateTime.parse(promoData['endDate']);
      DateTime currentDate = DateTime.now();

      if (currentDate.isBefore(startDate) || currentDate.isAfter(endDate)) {
        // Nếu không có khuyến mãi hợp lệ, trả về giá gốc
        return originalPrice;
      }

      // Chuyển đổi percentage thành double
      double percentage = (promoData['percentage']?.toDouble() ?? 0.0);

      // Tính giá tiền sau khi áp dụng khuyến mãi
      double discountedPrice = originalPrice * (1 - percentage / 100);

      return discountedPrice;
    } catch (e) {
      print("Lỗi khi áp dụng khuyến mãi: $e");
      rethrow;
    }
  }
}
