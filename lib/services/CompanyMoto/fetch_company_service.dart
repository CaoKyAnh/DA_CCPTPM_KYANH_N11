// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'dart:convert';

class FetchCompanyService {
  final String baseUrl = 'http://10.0.2.2:3000/api/companyMoto'; // URL API của bạn

  // Phương thức để lấy tất cả các công ty hoặc một công ty cụ thể theo ID
  Future<List<Map<String, dynamic>>> fetchCompanies({String? id}) async {
    try {
      final response = id != null
          ? await http.get(
              Uri.parse('$baseUrl/$id'), // Lấy thông tin công ty theo ID
              headers: {'Content-Type': 'application/json'},
            )
          : await http.get(
              Uri.parse(baseUrl), // Lấy tất cả các công ty
              headers: {'Content-Type': 'application/json'},
            );

      // Kiểm tra mã trạng thái HTTP trả về
      if (response.statusCode == 200) {
        // Nếu thành công, trả về danh sách các công ty
        List<dynamic> responseBody = json.decode(response.body);
        return responseBody.map((company) => company as Map<String, dynamic>).toList();
      } else {
        // Nếu có lỗi, ném ngoại lệ với mã trạng thái lỗi
        throw Exception('Failed to load companies. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print("Error fetching companies: $error"); // Log lỗi nếu có
      throw Exception('An error occurred while fetching companies');
    }
  }
}
