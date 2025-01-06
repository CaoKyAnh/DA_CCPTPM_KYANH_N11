import 'package:cloud_firestore/cloud_firestore.dart';

class FetchMotorcycleByLocationService {
  Future<List<dynamic>> fetchMotorcycles(String location) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      final querySnapshot = await firestore
          .collection('motorcycles')
          .where('address.city', isEqualTo: location)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception("Error fetching motorcycles by location: $e");
    }
  }
}
