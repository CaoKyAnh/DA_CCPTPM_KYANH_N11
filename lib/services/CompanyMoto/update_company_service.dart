import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateCompanyService {
  final String baseUrl =
      'http://10.0.2.2:3000/api/companyMoto/'; // Adjust URL if needed
  // Use this if running on a real device

  Future<void> updateCompanyMoto(String id, String name, bool isHide) async {
    final response = await http.put(
      Uri.parse('$baseUrl$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'isHide': isHide}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update company motto');
    }
  }
}
