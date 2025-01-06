import 'package:cloud_firestore/cloud_firestore.dart';

class MotorcycleService {
  final CollectionReference motorcyclesCollection =
      FirebaseFirestore.instance.collection('motorcycles');

  Future<Map<String, dynamic>?> getMotorcycleByNumberPlate(
      String numberPlate) async {
    try {
      QuerySnapshot querySnapshot = await motorcyclesCollection
          .where('numberPlate', isEqualTo: numberPlate)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data() as Map<String, dynamic>;
      }
      return null; // Nếu không tìm thấy document nào
    } catch (e) {
      print('Lỗi khi truy vấn dữ liệu: $e');
      return null;
    }
  }
}
